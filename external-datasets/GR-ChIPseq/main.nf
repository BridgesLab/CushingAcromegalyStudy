#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
 * GR ChIP-seq / CUT&RUN re-analysis pipeline (mm10 + hg38)
 * ---------------------------------------------------------------------------
 * Re-processes published adipocyte glucocorticoid-receptor (GR) ChIP-seq /
 * CUT&RUN datasets from raw reads, calls GR peaks, and produces clean peak
 * BED files. Each sample declares its own reference `genome` ('mm10' or
 * 'hg38'); the pipeline builds/obtains both references, aligns each run to
 * its native genome, calls peaks natively, and lifts hg38 consensus peaks
 * back to mm10 so they overlap the GSE236575 (mm10) chromatin natively.
 *
 * Downstream overlap / enrichment against the GSE236575 HFD differentially
 * accessible chromatin is done LOCALLY in the *.qmd reports, not here. This
 * pipeline only produces the small peak BEDs (+ optional bigwigs) that get
 * synced back to the local GR-ChIPseq folder.
 *
 * Conventions mirror ../snATACseq/GSE236575/main.nf: bowtie2 + samtools +
 * bedtools + sratoolkit + macs2 via environment-modules; fasterq-dump for SRA.
 */

params.outdir         = "results"
params.genome_dir     = "${params.outdir}/genome"
params.mapq_threshold = 30
params.macs2_qvalue   = 0.01
params.make_bigwig    = true          // set false to skip locus-track bigwigs

// ── Per-genome reference metadata ───────────────────────────────────────────
// Keyed by the `genome` field used in the sample sheet. Only genomes actually
// referenced by params.chip_samples are downloaded/built.
params.genomes = [
    mm10: [
        fasta_url:     'http://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/mm10.fa.gz',
        blacklist_url: 'https://github.com/Boyle-Lab/Blacklist/raw/master/lists/mm10-blacklist.v2.bed.gz',
        macs2_gsize:   'mm',
    ],
    hg38: [
        fasta_url:     'http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz',
        blacklist_url: 'https://github.com/Boyle-Lab/Blacklist/raw/master/lists/hg38-blacklist.v2.bed.gz',
        macs2_gsize:   'hs',
    ],
]

// ── Reuse an existing mm10 bowtie2 index (optional) ─────────────────────────
// The GSE236575 run already built mm10.fa + the bowtie2 index. Point these at
// those files to skip the (~1 h) mm10 download + index build. Leave null to
// build fresh. Only applies to mm10; hg38 is always downloaded/built.
//   params.prebuilt_fasta     = "../snATACseq/GSE236575/results/genome/mm10.fa"
//   params.prebuilt_index_dir = "../snATACseq/GSE236575/results/genome"
params.prebuilt_fasta     = null
params.prebuilt_index_dir = null      // directory containing mm10*.bt2

// ── Sample sheet ─────────────────────────────────────────────────────────────
// Every sequencing run is one entry, GR IP runs AND their matched controls.
//   id        : unique sample id (becomes the peak-file basename)
//   srr       : SRA run accession (fasterq-dump)
//   dataset   : grouping key for the consensus peak set (single-genome)
//   role      : 'ip'      = GR ChIP / CUT&RUN signal track
//               'control' = matched input / IgG (used as MACS2 -c)
//   treatment : free-text condition label (e.g. 'dex', 'chow') — metadata only
//   control   : id of the matched control run (for role:'ip'; null for controls)
//   genome    : 'mm10' or 'hg38' — reference this run is aligned to
//
// "GR binding" = every MACS2 peak in an IP vs its input/IgG control, regardless
// of ligand induction (per design decision). Multiple IPs may share one control.
// The IP↔control join is global (keyed on the control id). Consensus peaks are
// grouped by `dataset`; hg38 datasets are lifted to mm10 after consensus.

// Tier-1 — GSE64458 (Soccio et al., Lazar lab; PRJNA271059). In vivo mouse
// adipose GR ChIP-seq, chow diet, single-end, mm10. eWAT matches GSE236575's
// tissue; iWAT is a separate consensus group. Inputs are iWAT-only, so controls
// are strain-matched (B6/129) but not depot-matched.
def gse64458 = [
    [id:'GSE64458_input_B6',    srr:'SRR1732502', dataset:'GSE64458',      role:'control', treatment:'chow', control:null,                genome:'mm10'],
    [id:'GSE64458_input_129',   srr:'SRR1732503', dataset:'GSE64458',      role:'control', treatment:'chow', control:null,                genome:'mm10'],
    [id:'GSE64458_B6_eWAT_GR',  srr:'SRR1732507', dataset:'GSE64458_eWAT', role:'ip',      treatment:'chow', control:'GSE64458_input_B6', genome:'mm10'],
    [id:'GSE64458_129_eWAT_GR', srr:'SRR1732508', dataset:'GSE64458_eWAT', role:'ip',      treatment:'chow', control:'GSE64458_input_129',genome:'mm10'],
    [id:'GSE64458_B6_iWAT_GR',  srr:'SRR1732505', dataset:'GSE64458_iWAT', role:'ip',      treatment:'chow', control:'GSE64458_input_B6', genome:'mm10'],
    [id:'GSE64458_129_iWAT_GR', srr:'SRR1732506', dataset:'GSE64458_iWAT', role:'ip',      treatment:'chow', control:'GSE64458_input_129',genome:'mm10'],
]

// Tier-3 — GSE163061 (Sobreira/Lazar; PRJNA684576). Human patient-derived
// adipocyte GR ChIP-seq, dexamethasone, paired-end, hg38. 8 donors × 2 reps
// (16 IP runs) over one shared input. Lifted hg38→mm10 after consensus —
// cross-species, so supporting evidence (recovers ~30–50% of regions).
def gse163061_input = [id:'GSE163061_input', srr:'SRR13252595', dataset:'GSE163061_human', role:'control', treatment:'dex', control:null, genome:'hg38']
def gse163061_ips = (13252579..13252594).withIndex().collect { srr_num, i ->
    def donor = i.intdiv(2) + 1
    def rep   = (i % 2) + 1
    [id:"GSE163061_A${donor}_Dex_${rep}", srr:"SRR${srr_num}", dataset:'GSE163061_human',
     role:'ip', treatment:'dex', control:'GSE163061_input', genome:'hg38']
}

params.chip_samples = gse64458 + [gse163061_input] + gse163061_ips

log.info """
    =========================================
    GR ChIP-seq re-analysis (mm10 + hg38→mm10)
    =========================================
    Output dir     : ${params.outdir}
    MAPQ filter    : ${params.mapq_threshold}
    MACS2 q-value  : ${params.macs2_qvalue}
    Make bigwigs   : ${params.make_bigwig}
    Samples        : ${params.chip_samples.size()}
    Genomes        : ${params.chip_samples.collect { it.genome }.unique().join(', ')}
    Prebuilt mm10  : ${params.prebuilt_index_dir ?: 'no (will build)'}
    =========================================
    """
    .stripIndent()

/*
 * Download a reference genome FASTA. Generic over genome name.
 */
process DOWNLOAD_GENOME {
    tag "${genome}"
    publishDir "${params.genome_dir}", mode: 'copy'

    input:
    tuple val(genome), val(url)

    output:
    tuple val(genome), path("${genome}.fa"), emit: fasta

    script:
    """
    wget -O ${genome}.fa.gz '${url}'
    gunzip ${genome}.fa.gz
    """
}

/*
 * Build a bowtie2 index. Index prefix = genome name, so CHIP_ALIGN can do
 * `-x \${genome}`.
 */
process BUILD_BOWTIE2_INDEX {
    module 'Bioinformatics:bowtie2'
    tag "${genome}"
    publishDir "${params.genome_dir}", mode: 'copy'

    input:
    tuple val(genome), path(fasta)

    output:
    tuple val(genome), path("${genome}*.bt2"), emit: index

    script:
    """
    bowtie2-build --threads ${task.cpus} ${fasta} ${genome}
    """
}

/*
 * Chromosome sizes from a genome FASTA (required by bedGraphToBigWig)
 */
process GENOME_SIZES {
    module 'Bioinformatics:samtools/1.21'
    tag "${genome}"
    publishDir "${params.genome_dir}", mode: 'copy'

    input:
    tuple val(genome), path(fasta)

    output:
    tuple val(genome), path("${genome}.chrom.sizes"), emit: sizes

    script:
    """
    samtools faidx ${fasta}
    cut -f1,2 ${fasta}.fai > ${genome}.chrom.sizes
    """
}

/*
 * Download an ENCODE blacklist (per genome). Always run, even when the index
 * is prebuilt — the blacklist is tiny.
 */
process DOWNLOAD_BLACKLIST {
    tag "${genome}"
    publishDir "${params.outdir}/blacklist", mode: 'copy'

    input:
    tuple val(genome), val(url)

    output:
    tuple val(genome), path("${genome}-blacklist.bed"), emit: bed

    script:
    """
    wget -O ${genome}-blacklist.bed.gz '${url}'
    gunzip ${genome}-blacklist.bed.gz
    [ -s ${genome}-blacklist.bed ] || { echo "Blacklist empty"; exit 1; }
    echo "${genome} blacklist regions: \$(wc -l < ${genome}-blacklist.bed)"
    """
}

/*
 * Download FASTQ from SRA and align with bowtie2 (auto-detects PE/SE) to the
 * sample's native genome. The staged index files are named `<genome>*.bt2`,
 * so `-x \${sample.genome}` selects the right reference.
 */
process CHIP_ALIGN {
    module 'Bioinformatics:sratoolkit/3.1.1:bowtie2:samtools/1.21'
    tag "${sample.id}"
    publishDir "${params.outdir}/bam_raw/${sample.id}", mode: 'copy', pattern: "*_bowtie2.log"

    input:
    tuple val(sample), path(bowtie2_index)

    output:
    tuple val(sample), path("${sample.id}.bam"), path("${sample.id}.bam.bai"), emit: bam
    path "${sample.id}_bowtie2.log", emit: log

    script:
    def threads = task.cpus > 0 ? task.cpus : 4
    """
    set -e
    fasterq-dump ${sample.srr} --threads ${threads} --split-files --progress

    if [ -f ${sample.srr}_2.fastq ]; then
        echo "Paired-end detected"
        bowtie2 -x ${sample.genome} -1 ${sample.srr}_1.fastq -2 ${sample.srr}_2.fastq \\
            -p ${threads} --very-sensitive --no-unal \\
            2> ${sample.id}_bowtie2.log | samtools view -bS -o unsorted.bam -
    else
        echo "Single-end detected"
        bowtie2 -x ${sample.genome} -U ${sample.srr}.fastq \\
            -p ${threads} --very-sensitive --no-unal \\
            2> ${sample.id}_bowtie2.log | samtools view -bS -o unsorted.bam -
    fi

    samtools sort -@ ${threads} -m 800M -o ${sample.id}.bam unsorted.bam
    rm -f ${sample.srr}*.fastq unsorted.bam
    samtools index ${sample.id}.bam
    samtools quickcheck ${sample.id}.bam
    cat ${sample.id}_bowtie2.log
    """
}

/*
 * Filter BAM: MAPQ threshold + remove blacklisted regions (genome-matched).
 * PCR-duplicate removal is left to MACS2 (--keep-dup 1 default), which keeps
 * this step robust for both PE and SE data.
 */
process CHIP_FILTER {
    module 'Bioinformatics:samtools/1.21:bedtools2/2.31.1-zl7ag52'
    tag "${sample.id}"
    publishDir "${params.outdir}/bam_filtered/${sample.id}", mode: 'copy', pattern: "*.flagstat.txt"

    input:
    tuple val(sample), path(bam), path(bai), path(blacklist)

    output:
    tuple val(sample), path("${sample.id}.filtered.bam"), path("${sample.id}.filtered.bam.bai"), emit: bam
    path "${sample.id}.flagstat.txt", emit: flagstat

    script:
    def threads = task.cpus > 0 ? task.cpus : 4
    """
    set -e
    samtools view -b -q ${params.mapq_threshold} -@ ${threads} ${bam} > mapq.bam
    samtools index mapq.bam
    bedtools intersect -v -a mapq.bam -b ${blacklist} > ${sample.id}.filtered.bam
    samtools index ${sample.id}.filtered.bam
    samtools flagstat ${sample.id}.filtered.bam > ${sample.id}.flagstat.txt
    rm -f mapq.bam mapq.bam.bai
    """
}

/*
 * Call GR peaks with MACS2 (narrow; GR is a point-source factor).
 * IP vs its matched input/IgG control. Auto-selects BAMPE vs BAM by checking
 * for the paired flag; effective genome size from the genome metadata.
 */
process MACS2_CALLPEAK {
    tag "${sample.id}"
    module 'Bioinformatics:py-macs2/2.2.4-4abp2hm:samtools/1.21'
    publishDir "${params.outdir}/peaks/${sample.dataset}", mode: 'copy'

    input:
    tuple val(sample), path(ip_bam), path(ip_bai), path(ctrl_bam), path(ctrl_bai)

    output:
    tuple val(sample.dataset), val(sample.genome), path("${sample.id}_peaks.narrowPeak"), emit: peaks
    path "${sample.id}_peaks.xls",         emit: xls,     optional: true
    path "${sample.id}_summits.bed",       emit: summits, optional: true

    script:
    def gsize = params.genomes[sample.genome].macs2_gsize
    """
    set -e
    if [ "\$(samtools view -c -f 1 ${ip_bam})" -gt 0 ]; then FMT=BAMPE; else FMT=BAM; fi
    echo "MACS2 format: \$FMT  gsize: ${gsize}"
    macs2 callpeak \\
        -t ${ip_bam} \\
        -c ${ctrl_bam} \\
        -f \$FMT \\
        -g ${gsize} \\
        -q ${params.macs2_qvalue} \\
        -n ${sample.id} \\
        --outdir .
    echo "Peaks called: \$(wc -l < ${sample.id}_peaks.narrowPeak)"
    """
}

/*
 * Per-dataset consensus GR peak set: union of all IP narrowPeaks in the
 * dataset, merged (native genome coords). hg38 datasets are lifted to mm10
 * downstream.
 */
process CONSENSUS_PEAKS {
    module 'Bioinformatics:bedtools2/2.31.1-zl7ag52'
    tag "${dataset}"
    publishDir "${params.outdir}/peaks/${dataset}", mode: 'copy'

    input:
    tuple val(dataset), val(genome), path(narrowpeaks)

    output:
    tuple val(dataset), val(genome), path("${dataset}_GR_consensus.bed"), emit: bed

    script:
    """
    set -e
    cat ${narrowpeaks} \\
        | cut -f1-3 \\
        | sort -k1,1 -k2,2n \\
        | bedtools merge -i - > ${dataset}_GR_consensus.bed
    echo "${dataset} consensus GR peaks (${genome}): \$(wc -l < ${dataset}_GR_consensus.bed)"
    """
}

/*
 * Lift a non-mm10 consensus peak set to mm10 with UCSC liftOver, so it overlaps
 * the GSE236575 (mm10) chromatin natively. Downloads liftOver + the chain file
 * if not already present.
 */
process LIFTOVER_PEAKS {
    tag "${dataset}"
    publishDir "${params.outdir}/peaks/${dataset}", mode: 'copy'

    input:
    tuple val(dataset), val(genome), path(consensus)

    output:
    tuple val(dataset), path("${dataset}_GR_consensus.mm10.bed"), emit: bed

    script:
    // chain naming: hg38 -> hg38ToMm10.over.chain.gz
    def chain = "${genome}ToMm10.over.chain.gz"
    """
    set -e
    if command -v liftOver &>/dev/null; then
        LO=liftOver
    else
        # v369 build links against an older glibc — runs on the compute nodes
        # (the newer admin/exe/linux.x86_64 build needs GLIBC_2.29+ → fails here)
        wget -q http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v369/liftOver -O liftOver
        chmod +x liftOver
        LO=./liftOver
    fi
    wget -q http://hgdownload.soe.ucsc.edu/goldenPath/${genome}/liftOver/${chain} -O chain.gz
    gunzip chain.gz
    \$LO ${consensus} chain ${dataset}_GR_consensus.mm10.bed ${dataset}_unmapped.bed
    echo "${dataset} lifted ${genome}->mm10: \$(wc -l < ${dataset}_GR_consensus.mm10.bed) of \$(wc -l < ${consensus}) (unmapped: \$(grep -vc '^#' ${dataset}_unmapped.bed || echo 0))"
    """
}

/*
 * Optional CPM-normalised bigwig per IP sample for locus tracks. Uses the
 * genome-matched chrom.sizes. PE uses fragment coverage (-pc); SE read coverage.
 */
process CHIP_BIGWIG {
    module 'Bioinformatics:samtools/1.21:bedtools2/2.31.1-zl7ag52'
    tag "${sample.id}"
    publishDir "${params.outdir}/bigwig", mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai), path(chrom_sizes)

    output:
    tuple val(sample), path("${sample.id}.CPM.bw"), emit: bigwig

    script:
    """
    set -e
    if command -v bedGraphToBigWig &>/dev/null; then
        BG2BW=bedGraphToBigWig
    else
        wget -q http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v369/bedGraphToBigWig -O bedGraphToBigWig
        chmod +x bedGraphToBigWig
        BG2BW=./bedGraphToBigWig
    fi

    if [ "\$(samtools view -c -f 1 ${bam})" -gt 0 ]; then
        total=\$(samtools view -c -f 2 -F 4 ${bam})
        PCFLAG="-pc"
    else
        total=\$(samtools view -c -F 4 ${bam})
        PCFLAG=""
    fi
    scale=\$(python3 -c "print(1000000.0 / \${total})")

    bedtools genomecov -ibam ${bam} -bg \$PCFLAG -scale \${scale} \\
        | sort -k1,1 -k2,2n > ${sample.id}.bedgraph
    \${BG2BW} ${sample.id}.bedgraph ${chrom_sizes} ${sample.id}.CPM.bw
    rm -f ${sample.id}.bedgraph
    echo "BigWig: ${sample.id}.CPM.bw (total reads/fragments: \${total})"
    """
}

workflow {

    if (!params.chip_samples) {
        log.warn "params.chip_samples is empty — fill in the sample sheet (GR IPs + matched controls) before running."
    }

    // genomes actually referenced by the sample sheet
    def needed_genomes = params.chip_samples.collect { it.genome }.unique()
    def prebuilt_mm10  = (params.prebuilt_fasta && params.prebuilt_index_dir) as boolean
    // genomes that must be downloaded + index-built (mm10 skipped if prebuilt)
    def dl_genomes = needed_genomes.findAll { !(it == 'mm10' && prebuilt_mm10) }

    // ── Blacklists for every needed genome (tiny; always downloaded) ────────
    DOWNLOAD_BLACKLIST(
        Channel.from(needed_genomes).map { g -> [g, params.genomes[g].blacklist_url] }
    )
    all_blacklist = DOWNLOAD_BLACKLIST.out.bed     // [genome, bed]

    // ── Reference FASTA / index / sizes per genome ──────────────────────────
    DOWNLOAD_GENOME(
        Channel.from(dl_genomes).map { g -> [g, params.genomes[g].fasta_url] }
    )
    BUILD_BOWTIE2_INDEX(DOWNLOAD_GENOME.out.fasta)

    // prebuilt mm10 fasta/index folded in (if supplied and mm10 is needed)
    if (prebuilt_mm10 && ('mm10' in needed_genomes)) {
        prebuilt_fasta_ch = Channel.fromPath(params.prebuilt_fasta, checkIfExists: true)
            .map { f -> ['mm10', f] }
        prebuilt_index_ch = Channel.fromPath("${params.prebuilt_index_dir}/mm10*.bt2", checkIfExists: true)
            .collect().map { idx -> ['mm10', idx] }
    } else {
        prebuilt_fasta_ch = Channel.empty()
        prebuilt_index_ch = Channel.empty()
    }

    all_fasta = DOWNLOAD_GENOME.out.fasta.mix(prebuilt_fasta_ch)   // [genome, fasta]
    GENOME_SIZES(all_fasta)
    all_sizes = GENOME_SIZES.out.sizes                            // [genome, sizes]
    all_index = BUILD_BOWTIE2_INDEX.out.index.mix(prebuilt_index_ch) // [genome, [bt2...]]

    // ── Align each run to its native genome ─────────────────────────────────
    samples_ch = Channel.from(params.chip_samples)
    align_in = samples_ch
        .map { s -> [s.genome, s] }
        .combine(all_index, by: 0)
        .map { genome, s, index -> [s, index] }
    CHIP_ALIGN(align_in)

    // ── Filter (genome-matched blacklist) ───────────────────────────────────
    filter_in = CHIP_ALIGN.out.bam
        .map { s, bam, bai -> [s.genome, s, bam, bai] }
        .combine(all_blacklist, by: 0)
        .map { genome, s, bam, bai, bl -> [s, bam, bai, bl] }
    CHIP_FILTER(filter_in)

    // ── Pair each IP with its matched control, keyed on control id ──────────
    controls = CHIP_FILTER.out.bam
        .filter { sample, bam, bai -> sample.role == 'control' }
        .map    { sample, bam, bai -> [sample.id, bam, bai] }

    ips = CHIP_FILTER.out.bam
        .filter { sample, bam, bai -> sample.role == 'ip' }
        .map    { sample, bam, bai -> [sample.control, sample, bam, bai] }

    macs_in = ips
        .combine(controls, by: 0)
        .map { ctrl_id, sample, ip_bam, ip_bai, ctrl_bam, ctrl_bai ->
               [sample, ip_bam, ip_bai, ctrl_bam, ctrl_bai] }

    MACS2_CALLPEAK(macs_in)

    // ── Per-dataset consensus GR peak set (native coords) ───────────────────
    MACS2_CALLPEAK.out.peaks
        .groupTuple()                                  // [dataset, [genome...], [peaks...]]
        .map { dataset, genomes, peaks -> [dataset, genomes[0], peaks] }
        .set { peaks_by_dataset }
    CONSENSUS_PEAKS(peaks_by_dataset)

    // ── Lift non-mm10 consensus sets to mm10 ────────────────────────────────
    CONSENSUS_PEAKS.out.bed
        .filter { dataset, genome, bed -> genome != 'mm10' }
        .set { to_lift }
    LIFTOVER_PEAKS(to_lift)

    // ── Optional locus-track bigwigs (IP samples only) ──────────────────────
    if (params.make_bigwig) {
        bw_in = CHIP_FILTER.out.bam
            .filter { sample, bam, bai -> sample.role == 'ip' }
            .map    { sample, bam, bai -> [sample.genome, sample, bam, bai] }
            .combine(all_sizes, by: 0)
            .map    { genome, sample, bam, bai, sizes -> [sample, bam, bai, sizes] }
        CHIP_BIGWIG(bw_in)
    }
}

workflow.onComplete {
    log.info """
    Pipeline completed.
    GR peaks       : ${params.outdir}/peaks/<dataset>/
    Consensus BED  : ${params.outdir}/peaks/<dataset>/<dataset>_GR_consensus.bed (native)
    Lifted (hg38)  : ${params.outdir}/peaks/<dataset>/<dataset>_GR_consensus.mm10.bed
    Bigwigs        : ${params.outdir}/bigwig/
    Sync the small peak BEDs (+ optional bigwigs) back to the local GR-ChIPseq folder.
    """
}
