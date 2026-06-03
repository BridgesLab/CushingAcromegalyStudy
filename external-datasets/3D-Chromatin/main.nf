#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
 * 3T3-L1 adipocyte Hi-C → TAD pipeline (mm9 → mm10)
 * ---------------------------------------------------------------------------
 * Re-processes published 3T3-L1 adipogenesis Hi-C (Siersbaek et al. 2017,
 * GSE95533) from the deposited HiCUP-filtered read-pair lists, builds balanced
 * cooler contact matrices, calls TADs with two independent callers (cooltools
 * insulation + HiCExplorer hicFindTADs), and lifts the TAD coordinates from the
 * native mm9 build to mm10 so they overlap the GSE236575 (mm10) chromatin and
 * the GR-ChIPseq (mm10) peaks natively.
 *
 * IMPORTANT — what Hi-C exists in GSE95533: standard Hi-C is available only at
 * D0 (fibroblast), 4h, and D2 (early differentiation). There is NO D6/D7
 * mature-adipocyte Hi-C in this series (later timepoints have only ChIP/RNA).
 * D2 is therefore the most adipocyte-committed Hi-C available. TAD boundaries
 * are largely invariant across adipogenesis (the Siersbaek paper's own finding
 * is that promoter loops rewire while domain structure is broadly stable), so
 * D2 TADs are an acceptable proxy for mature-adipocyte domains for the
 * coarse-grained "are HFD peaks in GR-rich TADs?" question. This caveat is
 * carried explicitly in SUMMARY.md / the qmd. D0 can be built as a sensitivity
 * contrast (set params.stages = ['D0','D2']).
 *
 * Downstream overlap / enrichment against the GSE236575 HFD differentially
 * accessible chromatin and the GR ChIP peaks is done LOCALLY in tad-analysis.qmd,
 * not here. This pipeline only produces the small TAD BEDs (mm10) that get
 * synced back to the local 3D-Chromatin/results/tads/ folder.
 *
 * Conventions mirror ../GR-ChIPseq/main.nf: SLURM executor, environment-modules
 * for base tools, and the UCSC liftOver v369 binary downloaded on the node. The
 * Hi-C-specific tools (cooler, cooltools, hicexplorer) come from per-process
 * conda environments (conda.enabled = true in nextflow.config) rather than
 * cluster modules, so the pipeline is portable across HPCs that lack them.
 */

params.outdir       = "results"

// ── Genome / build ───────────────────────────────────────────────────────────
// GSE95533 is mm9. We build cool matrices in mm9 and lift the final TAD BEDs to
// mm10 (the assembly of every other sub-project in this repo).
params.genome              = 'mm9'
params.chromsizes_url      = 'https://hgdownload.soe.ucsc.edu/goldenPath/mm9/bigZips/mm9.chrom.sizes'
params.liftover_chain_url  = 'https://hgdownload.soe.ucsc.edu/goldenPath/mm9/liftOver/mm9ToMm10.over.chain.gz'
// keep only the canonical chromosomes for matrix construction / TAD calling
params.keep_chroms         = (1..19).collect { "chr${it}" } + ['chrX']

// ── Matrix / TAD-calling resolution ──────────────────────────────────────────
params.bin_base            = 10000        // base bin size for the cooler
params.tad_resolution      = 50000        // resolution TADs are called at
params.zoom_resolutions    = [10000, 25000, 50000, 100000, 250000]
// cooltools insulation windows (bp) — multiple windows = the sensitivity sweep
params.insulation_windows  = [100000, 250000, 500000]
params.second_caller       = true         // also run HiCExplorer hicFindTADs

// ── Sample sheet ─────────────────────────────────────────────────────────────
// One entry per deposited Hi-C replicate. `stage` is the grouping key: replicates
// of the same stage are pooled into one cooler for depth. The HiCUP raw file is a
// 6-col TSV (header: chr1 coord1 strand1 chr2 coord2 strand2).
//   id    : unique replicate id
//   gsm   : GEO sample accession (for the FTP path)
//   url   : direct FTP/HTTPS url to the *.hicup.raw.txt.gz
//   stage : differentiation timepoint (pool key)
def geo = { gsm, file -> "https://ftp.ncbi.nlm.nih.gov/geo/samples/${gsm[0..-4]}nnn/${gsm}/suppl/${file}" }

def hic_all = [
    [id:'HiC_D0_Exp1', gsm:'GSM2515982', stage:'D0', url:geo('GSM2515982','GSM2515982_HiC_D0_Exp1.hicup.raw.txt.gz')],
    [id:'HiC_D0_Exp2', gsm:'GSM2515983', stage:'D0', url:geo('GSM2515983','GSM2515983_HiC_D0_Exp2.hicup.raw.txt.gz')],
    [id:'HiC_D2_Exp1', gsm:'GSM2515986', stage:'D2', url:geo('GSM2515986','GSM2515986_HiC_D2_Exp1.hicup.raw.txt.gz')],
    [id:'HiC_D2_Exp2', gsm:'GSM2515987', stage:'D2', url:geo('GSM2515987','GSM2515987_HiC_D2_Exp2.hicup.raw.txt.gz')],
]

// Which stages to actually process. Default = D2 (most adipocyte-committed Hi-C).
// Add 'D0' for a fibroblast sensitivity contrast.
params.stages       = ['D2']
params.hic_samples  = hic_all.findAll { it.stage in params.stages }

log.info """
    =========================================
    3T3-L1 Hi-C → TAD pipeline (mm9 → mm10)
    =========================================
    Output dir        : ${params.outdir}
    Stages            : ${params.stages.join(', ')}
    Replicates        : ${params.hic_samples.size()}
    Base bin size     : ${params.bin_base}
    TAD resolution    : ${params.tad_resolution}
    Insulation windows: ${params.insulation_windows.join(', ')}
    Second caller     : ${params.second_caller ? 'HiCExplorer hicFindTADs' : 'no'}
    =========================================
    """
    .stripIndent()

/*
 * Canonical chromosome sizes for the native (mm9) build. Filtered to the main
 * chromosomes so the matrix excludes random/unplaced contigs.
 */
process DOWNLOAD_CHROMSIZES {
    tag "${params.genome}"
    publishDir "${params.outdir}/genome", mode: 'copy'

    output:
    path "${params.genome}.main.chrom.sizes", emit: sizes

    script:
    def keep = params.keep_chroms.join('|')
    """
    set -e
    wget -q -O all.chrom.sizes '${params.chromsizes_url}'
    # keep canonical chroms, in karyotype order (cooler bin order follows this file)
    awk 'BEGIN{OFS="\\t"} \$1 ~ /^(${keep})\$/' all.chrom.sizes \\
        | sort -k1,1V > ${params.genome}.main.chrom.sizes
    echo "kept chromosomes:"; cat ${params.genome}.main.chrom.sizes
    """
}

/*
 * Download one deposited HiCUP read-pair list (~0.4–0.9 GB gz per replicate).
 */
process DOWNLOAD_HIC {
    tag "${sample.id}"

    input:
    val sample

    output:
    tuple val(sample), path("${sample.id}.hicup.raw.txt.gz"), emit: raw

    script:
    """
    set -e
    wget -q -O ${sample.id}.hicup.raw.txt.gz '${sample.url}'
    [ -s ${sample.id}.hicup.raw.txt.gz ] || { echo "download empty"; exit 1; }
    """
}

/*
 * Convert a HiCUP raw read-pair list to a minimal 4-column pairs text
 * (chrom1 pos1 chrom2 pos2). cooler cload pairs auto-enforces upper-triangular
 * order (it flips lower-triangular records) and sorts internally, so no external
 * sort / pairix index is needed. We drop the header and restrict to the main
 * chromosomes here to keep the stream small.
 */
process HICUP_TO_PAIRS {
    tag "${sample.id}"
    module 'Bioinformatics'

    input:
    tuple val(sample), path(raw), path(chromsizes)

    output:
    tuple val(sample.stage), path("${sample.id}.pairs.gz"), emit: pairs

    script:
    """
    set -e
    # build a chrom whitelist from the sizes file
    cut -f1 ${chromsizes} | sort -u > keep.txt
    zcat ${raw} \\
      | awk 'BEGIN{OFS="\\t"} NR>1 {print \$1, \$2, \$4, \$5}' \\
      | awk 'BEGIN{OFS="\\t"; while((getline k < "keep.txt")>0) ok[k]=1}
             ok[\$1] && ok[\$3] {print}' \\
      | gzip > ${sample.id}.pairs.gz
    echo "${sample.id} cis+trans pairs on main chroms: \$(zcat ${sample.id}.pairs.gz | wc -l)"
    """
}

/*
 * Pool all replicate pairs for a stage into one balanced cooler, then zoomify to
 * a multi-resolution .mcool (ICE-balanced at each resolution). The balanced
 * matrix at params.tad_resolution feeds both TAD callers.
 */
process BUILD_COOL {
    tag "${stage}"
    module 'Bioinformatics'
    conda 'bioconda::cooler=0.10.2'
    publishDir "${params.outdir}/cool", mode: 'copy', pattern: "*.mcool"

    input:
    tuple val(stage), path(pairs), path(chromsizes)

    output:
    tuple val(stage), path("${stage}.mcool"), emit: mcool

    script:
    """
    set -e
    # pool replicates (cooler cload handles arbitrary order / triangularity)
    zcat ${pairs} > all.pairs
    cooler cload pairs \\
        -c1 1 -p1 2 -c2 3 -p2 4 \\
        --assembly ${params.genome} \\
        ${chromsizes}:${params.bin_base} all.pairs ${stage}.base.cool
    rm -f all.pairs

    cooler balance -p ${task.cpus} ${stage}.base.cool

    cooler zoomify -p ${task.cpus} --balance \\
        -r ${params.zoom_resolutions.join(',')} \\
        -o ${stage}.mcool ${stage}.base.cool
    echo "built ${stage}.mcool"; cooler info ${stage}.mcool::/resolutions/${params.tad_resolution}
    """
}

/*
 * TAD caller 1 — cooltools insulation. Computes the insulation profile at
 * params.tad_resolution over every requested window, flags boundaries (Li
 * thresholding), and emits the raw boundary table. Domains are assembled in
 * INSULATION_TO_TADS.
 */
process CALL_TADS_INSULATION {
    tag "${stage}"
    conda 'bioconda::cooltools=0.7.1'
    publishDir "${params.outdir}/tads", mode: 'copy', pattern: "*_insulation.tsv"

    input:
    tuple val(stage), path(mcool)

    output:
    tuple val(stage), path("${stage}_insulation.tsv"), emit: insulation

    script:
    def windows = params.insulation_windows.join(' ')
    """
    set -e
    cooltools insulation \\
        ${mcool}::/resolutions/${params.tad_resolution} \\
        ${windows} \\
        --threshold Li \\
        -o ${stage}_insulation.tsv
    echo "insulation rows: \$(wc -l < ${stage}_insulation.tsv)"
    """
}

/*
 * Convert the cooltools insulation boundary table to TAD-domain BEDs (mm9), one
 * per insulation window. A domain is the interval between two consecutive strong
 * boundaries on the same chromosome (is_boundary_<window> == True). This is the
 * standard insulation→domain assembly; tiny enough to do inline with awk/python.
 */
process INSULATION_TO_TADS {
    tag "${stage}"
    conda 'bioconda::pandas=2.2.2'
    publishDir "${params.outdir}/tads", mode: 'copy', pattern: "*.bed"

    input:
    tuple val(stage), path(insulation)

    output:
    tuple val(stage), val('insulation'), path("${stage}_insulation_tads.mm9.bed"), emit: tads

    script:
    """
    set -e
    python3 - <<'PY'
import pandas as pd
df = pd.read_csv("${insulation}", sep="\\t")
# pick the middle requested window as the primary domain set
wins = ${params.insulation_windows}
win = sorted(wins)[len(wins)//2]
bcol = f"is_boundary_{win}"
if bcol not in df.columns:
    bcol = [c for c in df.columns if c.startswith("is_boundary_")][0]
rows = []
for chrom, sub in df[df[bcol] == True].groupby("chrom"):
    starts = sorted(sub["start"].tolist())
    for a, b in zip(starts[:-1], starts[1:]):
        rows.append((chrom, a, b))
out = pd.DataFrame(rows, columns=["chrom","start","end"]).sort_values(["chrom","start"])
out.to_csv("${stage}_insulation_tads.mm9.bed", sep="\\t", header=False, index=False)
print(f"{len(out)} insulation TADs (window {win}) for ${stage}")
PY
    """
}

/*
 * TAD caller 2 (sensitivity) — HiCExplorer hicFindTADs on the same balanced
 * matrix. An independent algorithm (TAD-separation score) to confirm the
 * insulation conclusions do not depend on the caller. Emits a domains BED (mm9).
 */
process CALL_TADS_HICEXPLORER {
    tag "${stage}"
    conda 'bioconda::hicexplorer=3.7.6'
    publishDir "${params.outdir}/tads", mode: 'copy', pattern: "*_domains.bed"

    input:
    tuple val(stage), path(mcool)

    output:
    tuple val(stage), val('hicexplorer'), path("${stage}_hicexplorer_tads.mm9.bed"), emit: tads

    script:
    """
    set -e
    hicFindTADs \\
        -m ${mcool}::/resolutions/${params.tad_resolution} \\
        --outPrefix ${stage}_hicexp \\
        --correctForMultipleTesting fdr \\
        -p ${task.cpus}
    cut -f1-3 ${stage}_hicexp_domains.bed > ${stage}_hicexplorer_tads.mm9.bed
    echo "hicexplorer TADs for ${stage}: \$(wc -l < ${stage}_hicexplorer_tads.mm9.bed)"
    """
}

/*
 * Lift a TAD BED from mm9 to mm10 with UCSC liftOver (same node-download pattern
 * as ../GR-ChIPseq/main.nf). Output is the canonical synced-back artifact.
 */
process LIFTOVER_TADS {
    tag "${stage}_${caller}"
    publishDir "${params.outdir}/tads", mode: 'copy'

    input:
    tuple val(stage), val(caller), path(tads_mm9)

    output:
    tuple val(stage), val(caller), path("${stage}_${caller}_tads.mm10.bed"), emit: tads

    script:
    """
    set -e
    if command -v liftOver &>/dev/null; then
        LO=liftOver
    else
        wget -q http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v369/liftOver -O liftOver
        chmod +x liftOver
        LO=./liftOver
    fi
    wget -q '${params.liftover_chain_url}' -O chain.gz
    gunzip -f chain.gz
    \$LO ${tads_mm9} chain ${stage}_${caller}_tads.mm10.bed ${stage}_${caller}_unmapped.bed
    echo "${stage} ${caller} lifted mm9->mm10: \$(wc -l < ${stage}_${caller}_tads.mm10.bed) of \$(wc -l < ${tads_mm9}) (unmapped: \$(grep -vc '^#' ${stage}_${caller}_unmapped.bed || echo 0))"
    """
}

workflow {

    if (!params.hic_samples) {
        log.warn "params.hic_samples is empty — check params.stages against the sample sheet."
    }

    DOWNLOAD_CHROMSIZES()
    sizes = DOWNLOAD_CHROMSIZES.out.sizes

    // ── Download + convert each replicate to a pairs stream ─────────────────
    DOWNLOAD_HIC(Channel.from(params.hic_samples))
    to_pairs = DOWNLOAD_HIC.out.raw.combine(sizes)        // [sample, raw, sizes]
    HICUP_TO_PAIRS(to_pairs)

    // ── Pool replicate pairs per stage, build balanced mcool ────────────────
    pairs_by_stage = HICUP_TO_PAIRS.out.pairs
        .groupTuple()                                     // [stage, [pairs...]]
        .combine(sizes)                                   // [stage, [pairs...], sizes]
    BUILD_COOL(pairs_by_stage)

    // ── Caller 1: cooltools insulation → domains ────────────────────────────
    CALL_TADS_INSULATION(BUILD_COOL.out.mcool)
    INSULATION_TO_TADS(CALL_TADS_INSULATION.out.insulation)

    // ── Caller 2 (optional sensitivity): HiCExplorer ────────────────────────
    tad_sets = INSULATION_TO_TADS.out.tads
    if (params.second_caller) {
        CALL_TADS_HICEXPLORER(BUILD_COOL.out.mcool)
        tad_sets = tad_sets.mix(CALL_TADS_HICEXPLORER.out.tads)
    }

    // ── Lift every TAD set mm9 → mm10 ───────────────────────────────────────
    LIFTOVER_TADS(tad_sets)
}

workflow.onComplete {
    log.info """
    Pipeline completed.
    Multi-res cooler : ${params.outdir}/cool/<stage>.mcool
    Insulation table : ${params.outdir}/tads/<stage>_insulation.tsv
    TAD BEDs (mm9)   : ${params.outdir}/tads/<stage>_<caller>_tads.mm9.bed
    TAD BEDs (mm10)  : ${params.outdir}/tads/<stage>_<caller>_tads.mm10.bed   <- sync these back
    Sync the small mm10 TAD BEDs back to the local 3D-Chromatin/results/tads/ folder,
    then render tad-analysis.qmd for the Stage 1 enrichment.
    """
}
