#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
 * Differential ATAC-seq peak analysis pipeline (GSE236575, Hinte et al. 2023)
 *
 * Re-processes raw FASTQ from SRA, filters and dedups BAMs, calls peaks with
 * MACS2, removes ENCODE blacklist regions, runs DESeq2 differential analysis
 * (HFD vs CHD), then runs AME and HOMER motif enrichment.
 *
 * The previous version of this pipeline used the authors' pre-called peaks
 * from GEO and had a chromosome-naming mismatch (Ensembl-style "1, MT" in
 * peaks vs UCSC-style "chr1, chrM" in BAMs) plus a non-functional chrM
 * filter. Both are fixed here. Hinte's pre-called peaks are still
 * downloaded but only used for a concordance comparison.
 */

params.sra_accession   = "PRJNA991593"
params.geo_accession   = "GSE236575"
params.outdir          = "results"
params.genome_dir      = "${params.outdir}/genome"
params.fdr_threshold   = 0.05
params.lfc_threshold   = 1.0
params.macs2_qvalue    = 0.01      // Hinte reported "FDR 0.01% stringent"; matched here
params.mapq_threshold  = 30        // post-alignment MAPQ filter
params.blacklist_url   = "https://github.com/Boyle-Lab/Blacklist/raw/master/lists/mm10-blacklist.v2.bed.gz"

// ── RNA-seq (TRAP) branch — GSE236578 ──────────────────────────────────────
// Translating Ribosome Affinity Purification (TRAP) from the same
// AdipER-Cre/NuTRAP eWAT adipocytes used for ATAC-seq (Hinte et al. 2024).
// Library: paired-end 150 bp, template switching (Maxima H Minus RT),
// unstranded. Matched 3×CHD + 3×HFD; weight-loss arms excluded.
// Parent superseries: GSE236580 (PMID 39558077).
//
// GSE236578 sample → SRX → SRR accession map:
//   GSM7558266 TRAP_C_short_1  SRX20903626 → SRR25152278
//   GSM7558271 TRAP_C_short_2  SRX20903630 → SRR25152274
//   GSM7558276 TRAP_C_short_3  SRX20903638 → SRR25152266
//   GSM7558267 TRAP_H_short_1  SRX20903627 → SRR25152277
//   GSM7558272 TRAP_H_short_2  SRX20903631 → SRR25152273
//   GSM7558277 TRAP_H_short_3  SRX20903639 → SRR25152265
params.trap_samples = [
    [id: 'CHD_1', srr: 'SRR25152278', condition: 'CHD'],
    [id: 'CHD_2', srr: 'SRR25152274', condition: 'CHD'],
    [id: 'CHD_3', srr: 'SRR25152266', condition: 'CHD'],
    [id: 'HFD_1', srr: 'SRR25152277', condition: 'HFD'],
    [id: 'HFD_2', srr: 'SRR25152273', condition: 'HFD'],
    [id: 'HFD_3', srr: 'SRR25152265', condition: 'HFD'],
]
// GENCODE vM25: last mm10 (GRCm38) annotation; same genome build as ATAC
params.gtf_url       = "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.annotation.gtf.gz"
params.star_overhang = 149              // PE150 readLength - 1
params.rnaseq_fdr    = 0.05
params.rnaseq_lfc    = 0.585            // log2(1.5); softer bar than ATAC — n=3 limits power
params.rnaseq_outdir = "${params.outdir}/rnaseq"
// Effective genome size for mm10 RPGC normalization (excludes N's)
params.mm10_effective_gs = 2494787188

// SRA sample information - HFD and CHD samples only.
// GSE236575 also contains LCHD/LHFD (weight-loss arms) and CC/HC (other
// comparison arms) which are intentionally excluded from this analysis.
params.sra_samples = [
    [id: 'CHD_1', srr: 'SRR25146881', condition: 'CHD'],
    [id: 'CHD_2', srr: 'SRR25146878', condition: 'CHD'],
    [id: 'CHD_3', srr: 'SRR25146873', condition: 'CHD'],
    [id: 'HFD_1', srr: 'SRR25146870', condition: 'HFD'],
    [id: 'HFD_2', srr: 'SRR25146875', condition: 'HFD'],
    [id: 'HFD_3', srr: 'SRR25146880', condition: 'HFD']
]

log.info """
    =========================================
    ATAC-seq Differential Peak Analysis
    =========================================
    SRA Project        : ${params.sra_accession}
    GEO Accession      : ${params.geo_accession}
    Output dir         : ${params.outdir}
    DESeq2 FDR         : ${params.fdr_threshold}
    DESeq2 |LFC|       : ${params.lfc_threshold}
    MACS2 q-value      : ${params.macs2_qvalue}
    BAM MAPQ threshold : ${params.mapq_threshold}
    Blacklist          : ${params.blacklist_url}
    =========================================
    """
    .stripIndent()

/*
 * Download mm10 reference genome (UCSC; chr-prefixed)
 */
process DOWNLOAD_GENOME {
    publishDir "${params.genome_dir}", mode: 'copy'

    output:
    path "mm10.fa", emit: fasta

    script:
    """
    echo "Downloading mm10 genome from UCSC..."
    wget -O mm10.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/mm10.fa.gz
    gunzip mm10.fa.gz
    echo "Genome download complete"
    """
}

/*
 * Build bowtie2 index
 */
process BUILD_BOWTIE2_INDEX {
    publishDir "${params.genome_dir}", mode: 'copy'

    input:
    path fasta

    output:
    path "mm10*.bt2", emit: index
    path "mm10.fa",   emit: fasta

    script:
    """
    bowtie2-build --threads ${task.cpus} ${fasta} mm10
    """
}

/*
 * Generate chromosome sizes (used by MACS2 / blacklist intersect)
 */
process GENOME_SIZES {
    publishDir "${params.genome_dir}", mode: 'copy'

    input:
    path fasta

    output:
    path "mm10.chrom.sizes", emit: sizes

    script:
    """
    samtools faidx ${fasta}
    cut -f1,2 ${fasta}.fai > mm10.chrom.sizes
    """
}

/*
 * Download ENCODE mm10 blacklist (chr-prefixed v2; Boyle Lab)
 */
process DOWNLOAD_BLACKLIST {
    publishDir "${params.outdir}/blacklist", mode: 'copy'

    output:
    path "mm10-blacklist.v2.bed", emit: bed

    script:
    """
    wget -O mm10-blacklist.v2.bed.gz '${params.blacklist_url}'
    gunzip mm10-blacklist.v2.bed.gz
    if [ ! -s mm10-blacklist.v2.bed ]; then
        echo "ERROR: Blacklist download empty"
        exit 1
    fi
    echo "Blacklist regions: \$(wc -l < mm10-blacklist.v2.bed)"
    """
}

/*
 * Download Hinte's pre-called peaks for concordance comparison only.
 * Not used as the working peak set (we re-call below with MACS2).
 */
process DOWNLOAD_GEO_PEAKS {
    publishDir "${params.outdir}/geo_data", mode: 'copy'

    output:
    path "GSE236575_RAW.tar"

    script:
    """
    wget -O GSE236575_RAW.tar \
        'https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE236575&format=file'
    """
}

/*
 * Extract Hinte CHD/HFD BED files for the concordance check.
 *
 * GEO supplementary file naming is not 100% reliable across studies, so we
 * use a substring filter: keep filenames containing CHD or HFD, but exclude
 * LCHD, LHFD, CC, HC (other arms of the study). All replicates within a
 * condition are merged into hinte_CHD.bed / hinte_HFD.bed -- the concordance
 * check operates per condition rather than per replicate, so we don't need
 * to parse replicate numbers out of arbitrary filename conventions.
 *
 * file_list.txt records which input files contributed to which condition
 * for traceability.
 */
process EXTRACT_BED_FILES {
    publishDir "${params.outdir}/bed_files", mode: 'copy'

    input:
    path tar_file

    output:
    path "hinte_*.bed", emit: bed_files
    path "file_list.txt", emit: file_list

    script:
    """
    set -e
    mkdir -p _all
    tar -xf ${tar_file} -C _all

    echo "=== All BED files in tar ===" > file_list.txt
    ls _all/*.bed.gz 2>/dev/null | sort >> file_list.txt || true

    for cond in CHD HFD; do
        # Substring match for the condition, excluding the other study arms
        files=\$(ls _all/*.bed.gz 2>/dev/null | grep "\${cond}" | grep -v -E '(LCHD|LHFD|CC|HC)' || true)

        if [ -z "\$files" ]; then
            echo "ERROR: no \${cond} BED files found in tar." >&2
            echo "Files present:" >&2
            ls _all/ >&2
            exit 1
        fi

        echo "" >> file_list.txt
        echo "=== \${cond} files used ===" >> file_list.txt
        echo "\$files" | tr ' ' '\\n' >> file_list.txt

        # Merge all replicates for this condition, normalize Ensembl->UCSC chr
        # naming, sort, and bedtools merge.
        gunzip -c \$files | \
            awk 'BEGIN{OFS="\\t"}
                 {
                   c=\$1
                   if (c=="MT") c="chrM"
                   else if (c ~ /^(chr|GL|JH)/) c=c
                   else c="chr"c
                   print c, \$2, \$3
                 }' | \
            sort -k1,1 -k2,2n | \
            bedtools merge -i - > "hinte_\${cond}.bed"

        echo "hinte_\${cond}.bed: \$(wc -l < hinte_\${cond}.bed) merged peaks" >> file_list.txt
    done

    echo ""
    echo "=== file_list.txt ==="
    cat file_list.txt
    """
}

/*
 * Download FASTQ from SRA and align with bowtie2 (ATAC parameters).
 * Outputs a sorted, indexed raw BAM. Filtering happens downstream.
 */
process DOWNLOAD_AND_ALIGN {
    tag "${sample.id}"
    publishDir "${params.outdir}/bam_files/${sample.id}", mode: 'copy', pattern: "*.{bam,bai,log}"

    input:
    val sample
    path bowtie2_index

    output:
    tuple val(sample.id), val(sample.condition), path("${sample.id}.raw.bam"), path("${sample.id}.raw.bam.bai"), emit: bam
    path "${sample.id}_bowtie2.log", emit: align_log

    script:
    def threads = task.cpus > 0 ? task.cpus : 1
    """
    set -e
    fasterq-dump ${sample.srr} --threads ${threads} --split-files --progress

    if [ -f ${sample.srr}_2.fastq ]; then
        # ATAC paired-end alignment: -X 2000 allows long fragments common in ATAC libraries
        bowtie2 -x mm10 \
            -1 ${sample.srr}_1.fastq -2 ${sample.srr}_2.fastq \
            -p ${threads} \
            --very-sensitive -X 2000 --no-mixed --no-discordant \
            2> ${sample.id}_bowtie2.log | \
            samtools view -bS -o unsorted.bam -
    else
        bowtie2 -x mm10 -U ${sample.srr}.fastq \
            -p ${threads} --very-sensitive \
            2> ${sample.id}_bowtie2.log | \
            samtools view -bS -o unsorted.bam -
    fi

    samtools sort -@ ${threads} -m 800M -o ${sample.id}.raw.bam unsorted.bam
    samtools index ${sample.id}.raw.bam
    samtools quickcheck ${sample.id}.raw.bam

    rm -f ${sample.srr}*.fastq unsorted.bam

    echo "Alignment statistics:"
    cat ${sample.id}_bowtie2.log
    """
}

/*
 * ATAC BAM cleanup: properly paired only, MAPQ filter, mark+remove duplicates,
 * remove mitochondrial reads, remove blacklist regions.
 *
 * Filter flag 1804 = unmapped, mate unmapped, secondary, QC fail, supplementary.
 */
process FILTER_BAM {
    tag "${sample_id}"
    publishDir "${params.outdir}/bam_files/${sample_id}", mode: 'copy', pattern: "*.{bam,bai,txt}"

    input:
    tuple val(sample_id), val(condition), path(raw_bam), path(raw_bai)
    path blacklist

    output:
    tuple val(sample_id), val(condition), path("${sample_id}.clean.bam"), path("${sample_id}.clean.bam.bai"), emit: bam
    path "${sample_id}.filter_stats.txt", emit: stats

    script:
    def threads = task.cpus > 0 ? task.cpus : 1
    """
    set -e

    echo "=== ${sample_id} BAM filtering ===" > ${sample_id}.filter_stats.txt
    echo "Raw reads: \$(samtools view -c ${raw_bam})" >> ${sample_id}.filter_stats.txt
    echo "Mitochondrial (chrM) reads: \$(samtools view -c ${raw_bam} chrM)" >> ${sample_id}.filter_stats.txt

    # 1. Properly paired, both mapped, primary, MAPQ filter
    samtools view -@ ${threads} -b -f 2 -F 1804 -q ${params.mapq_threshold} \
        ${raw_bam} > step1.bam
    echo "After flag/MAPQ filter: \$(samtools view -c step1.bam)" >> ${sample_id}.filter_stats.txt

    # 2. Mark and remove duplicates (markdup needs name-sort -> fixmate -> coord-sort)
    samtools sort -n -@ ${threads} step1.bam -o step1.namesort.bam
    samtools fixmate -m -@ ${threads} step1.namesort.bam step1.fixmate.bam
    samtools sort -@ ${threads} step1.fixmate.bam -o step1.coordsort.bam
    samtools markdup -r -@ ${threads} step1.coordsort.bam step2.dedup.bam
    echo "After dedup: \$(samtools view -c step2.dedup.bam)" >> ${sample_id}.filter_stats.txt

    # 3. Remove mitochondrial reads
    samtools index step2.dedup.bam
    CHRS=\$(samtools view -H step2.dedup.bam | awk '/^@SQ/ {sub("SN:","",\$2); print \$2}' | grep -v -E '^(chrM|MT)\$' | tr '\\n' ' ')
    samtools view -@ ${threads} -b step2.dedup.bam \$CHRS > step3.nomito.bam
    samtools index step3.nomito.bam
    echo "After chrM removal: \$(samtools view -c step3.nomito.bam)" >> ${sample_id}.filter_stats.txt

    # 4. Remove reads overlapping ENCODE blacklist (ENCODE-style: bedtools intersect -v).
    #    Pair-mate integrity is approximate (one mate in blacklist removes that mate).
    bedtools intersect -v -abam step3.nomito.bam -b ${blacklist} > ${sample_id}.clean.bam
    samtools index ${sample_id}.clean.bam
    echo "After blacklist removal: \$(samtools view -c ${sample_id}.clean.bam)" >> ${sample_id}.filter_stats.txt

    rm -f step1.bam step1.namesort.bam step1.fixmate.bam step1.coordsort.bam \
          step2.dedup.bam step2.dedup.bam.bai step3.nomito.bam step3.nomito.bam.bai

    cat ${sample_id}.filter_stats.txt
    """
}

/*
 * MACS2 narrow-peak calling per sample, paired-end mode.
 * --shift / --extsize are not used because BAMPE handles fragment ends directly.
 */
process CALL_PEAKS_MACS2 {
    tag "${sample_id}"
    module 'Bioinformatics:py-macs2'
    publishDir "${params.outdir}/macs2_peaks/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(bam), path(bai)

    output:
    tuple val(sample_id), val(condition), path("${sample_id}_peaks.narrowPeak"), emit: peaks
    path "${sample_id}_*.{xls,bed}", optional: true

    script:
    """
    macs2 callpeak \
        -t ${bam} \
        -f BAMPE \
        -g mm \
        -q ${params.macs2_qvalue} \
        --nomodel \
        --keep-dup all \
        -n ${sample_id} \
        --outdir .
    echo "Peaks called for ${sample_id}: \$(wc -l < ${sample_id}_peaks.narrowPeak)"
    """
}

/*
 * Build union peak set from all 6 MACS2 narrowPeak files.
 * Removes chrM (defensive) and blacklist regions.
 */
process CREATE_UNION_PEAKS {
    publishDir "${params.outdir}/peaks", mode: 'copy'

    input:
    path peak_files
    path blacklist

    output:
    path "union_peaks.bed", emit: union_peaks
    path "union_peaks.saf", emit: union_saf
    path "peak_stats.txt", emit: stats

    script:
    """
    cat ${peak_files} | cut -f1-3 | \
        awk '\$1!="chrM" && \$1!="MT"' | \
        sort -k1,1 -k2,2n | \
        bedtools merge -i - > union.tmp.bed

    # Remove blacklist regions
    bedtools intersect -v -a union.tmp.bed -b ${blacklist} > union_peaks.bed
    rm union.tmp.bed

    awk 'BEGIN{OFS="\\t"} {print "peak_"NR, \$1, \$2, \$3, "+"}' union_peaks.bed > union_peaks.saf

    {
      echo "Union peaks (post-blacklist, no chrM): \$(wc -l < union_peaks.bed)"
      echo "Total genomic coverage: \$(awk '{sum+=\$3-\$2} END{print sum}' union_peaks.bed) bp"
      echo "Per-chromosome:"
      cut -f1 union_peaks.bed | sort | uniq -c
    } > peak_stats.txt
    cat peak_stats.txt
    """
}

/*
 * Concordance check: how well do MACS2 peaks recapitulate Hinte's pre-called peaks?
 *
 * Hinte BEDs are merged-per-condition (hinte_CHD.bed, hinte_HFD.bed). For each
 * MACS2 sample we report overlap and Jaccard against the matching condition's
 * Hinte set. Also reports condition-level merged MACS2 vs Hinte for an overall
 * comparison.
 */
process COMPARE_TO_HINTE {
    publishDir "${params.outdir}/hinte_concordance", mode: 'copy'

    input:
    path macs2_peaks
    path hinte_beds

    output:
    path "concordance_report.txt"
    path "*_jaccard.txt", optional: true

    script:
    """
    set -e
    > concordance_report.txt
    echo -e "level\\tsample\\tMACS2_peaks\\tHinte_peaks\\tMACS2_overlapping\\tJaccard" >> concordance_report.txt

    for s in CHD_1 CHD_2 CHD_3 HFD_1 HFD_2 HFD_3; do
        macs="\${s}_peaks.narrowPeak"
        cond=\$(echo \$s | cut -d_ -f1)
        hin="hinte_\${cond}.bed"
        if [ ! -s "\$macs" ] || [ ! -s "\$hin" ]; then
            echo -e "per-sample\\t\${s}\\tMISSING (\$macs or \$hin)" >> concordance_report.txt
            continue
        fi
        macs_n=\$(wc -l < "\$macs")
        hin_n=\$(wc -l < "\$hin")
        sort -k1,1 -k2,2n "\$macs" | cut -f1-3 > _m.bed
        sort -k1,1 -k2,2n "\$hin"  > _h.bed
        overlap=\$(bedtools intersect -u -a _m.bed -b _h.bed | wc -l)
        jacc=\$(bedtools jaccard -a _m.bed -b _h.bed | tail -n1 | awk '{print \$3}')
        bedtools jaccard -a _m.bed -b _h.bed > "\${s}_jaccard.txt"
        echo -e "per-sample\\t\${s}\\t\${macs_n}\\t\${hin_n}\\t\${overlap}\\t\${jacc}" >> concordance_report.txt
        rm _m.bed _h.bed
    done

    # Condition-level overall comparison: union of MACS2 calls per condition vs Hinte's merged set
    for cond in CHD HFD; do
        macs_files=\$(ls \${cond}_*_peaks.narrowPeak 2>/dev/null || true)
        hin="hinte_\${cond}.bed"
        if [ -z "\$macs_files" ] || [ ! -s "\$hin" ]; then
            echo -e "condition\\t\${cond}\\tMISSING" >> concordance_report.txt
            continue
        fi
        cat \$macs_files | cut -f1-3 | sort -k1,1 -k2,2n | bedtools merge -i - > _macs_cond.bed
        macs_n=\$(wc -l < _macs_cond.bed)
        hin_n=\$(wc -l < "\$hin")
        overlap=\$(bedtools intersect -u -a _macs_cond.bed -b "\$hin" | wc -l)
        jacc=\$(bedtools jaccard -a _macs_cond.bed -b "\$hin" | tail -n1 | awk '{print \$3}')
        bedtools jaccard -a _macs_cond.bed -b "\$hin" > "\${cond}_merged_jaccard.txt"
        echo -e "condition\\t\${cond}\\t\${macs_n}\\t\${hin_n}\\t\${overlap}\\t\${jacc}" >> concordance_report.txt
        rm _macs_cond.bed
    done

    cat concordance_report.txt
    """
}

/*
 * featureCounts on the union peak set
 */
process COUNT_PEAKS {
    tag "${sample_id}"
    publishDir "${params.outdir}/counts", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(bam), path(bai)
    path saf

    output:
    tuple val(sample_id), val(condition), path("${sample_id}_counts.txt"), emit: counts
    tuple val(sample_id), path("${sample_id}_counts.txt.summary"), emit: summary

    script:
    def threads = task.cpus > 0 ? task.cpus : 1
    """
    featureCounts \
        -F SAF \
        -a ${saf} \
        -o ${sample_id}_counts.txt \
        -p --countReadPairs -B -C \
        -T ${threads} \
        ${bam}
    """
}

/*
 * FRiP and basic ATAC QC (fraction of reads in peaks, fragment-size distribution).
 * Input tuple is the sample_id-keyed join of FILTER_BAM.out.bam x COUNT_PEAKS.out.summary.
 */
process ATAC_QC {
    tag "${sample_id}"
    publishDir "${params.outdir}/qc", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(bam), path(bai), path(summary_file)

    output:
    path "${sample_id}_qc.txt"
    path "${sample_id}_fragsize.txt"

    script:
    """
    total=\$(samtools view -c ${bam})
    # featureCounts .summary is two columns: Status<TAB>count.
    # The "Assigned" line (line 2) gives reads in peaks.
    in_peaks=\$(awk -F'\\t' '\$1=="Assigned" {print \$2}' ${summary_file})
    if [ -z "\$in_peaks" ] || [ "\$in_peaks" = "0" ]; then
        in_peaks=0
        frip="NA"
    else
        frip=\$(awk -v a=\$in_peaks -v b=\$total 'BEGIN{ if (b>0) printf "%.4f", a/b; else print "NA" }')
    fi

    {
        echo -e "sample\\t${sample_id}"
        echo -e "condition\\t${condition}"
        echo -e "clean_reads\\t\$total"
        echo -e "reads_in_peaks\\t\$in_peaks"
        echo -e "FRiP\\t\$frip"
    } > ${sample_id}_qc.txt

    # Fragment-size distribution from properly paired reads (TLEN > 0, < 2000)
    samtools view -f 2 ${bam} | awk '\$9>0 && \$9<2000 {print \$9}' | \
        sort -n | uniq -c | awk 'BEGIN{OFS="\\t"} {print \$2,\$1}' > ${sample_id}_fragsize.txt

    cat ${sample_id}_qc.txt
    """
}

/*
 * Combine per-sample featureCounts files into a single matrix
 */
process COMBINE_COUNTS {
    publishDir "${params.outdir}/count_matrix", mode: 'copy'

    input:
    tuple val(sample_ids), val(conditions), path(count_files)

    output:
    path "count_matrix.txt", emit: count_matrix
    path "sample_metadata.txt", emit: metadata

    script:
    """
    #!/usr/bin/env python3
    sample_ids = "${sample_ids}".strip('[]').split(', ')
    conditions = "${conditions}".strip('[]').split(', ')
    count_files = "${count_files}".split()

    all_data = {}
    gene_ids = []

    for i, count_file in enumerate(count_files):
        sample_id = sample_ids[i]
        counts = []
        with open(count_file) as f:
            for line in f:
                if line.startswith('#'):
                    continue
                parts = line.strip().split('\\t')
                if parts[0] == 'Geneid':
                    continue
                if i == 0:
                    gene_ids.append(parts[0])
                counts.append(parts[-1])
        all_data[sample_id] = counts

    with open('count_matrix.txt', 'w') as f:
        f.write('Geneid\\t' + '\\t'.join(sample_ids) + '\\n')
        for i, gene_id in enumerate(gene_ids):
            row = [gene_id] + [all_data[s][i] for s in sample_ids]
            f.write('\\t'.join(row) + '\\n')

    with open('sample_metadata.txt', 'w') as f:
        f.write('sample\\tcondition\\n')
        for s, c in zip(sample_ids, conditions):
            f.write(f'{s}\\t{c}\\n')

    print(f"count_matrix.txt: {len(gene_ids)} peaks x {len(sample_ids)} samples")
    """
}

/*
 * DESeq2 differential analysis (HFD vs CHD).
 * Output BED files use chr-prefixed naming throughout.
 */
process DESEQ2_ANALYSIS {
    publishDir "${params.outdir}/deseq2", mode: 'copy'

    input:
    path count_matrix
    path metadata
    path union_peaks

    output:
    path "deseq2_results.txt", emit: results
    path "deseq2_normalized_counts.txt", emit: norm_counts
    path "deseq2_plots.pdf", emit: plots
    path "significant_peaks.bed", emit: sig_peaks
    path "HFD_specific_peaks.bed", emit: hfd_peaks
    path "CHD_specific_peaks.bed", emit: chd_peaks
    path "shared_peaks.bed", emit: shared_peaks

    script:
    """
    #!/usr/bin/env Rscript

    suppressPackageStartupMessages({
        library(DESeq2)
        library(ggplot2)
    })

    counts   <- read.table("${count_matrix}", header=TRUE, row.names=1, sep="\\t", check.names=FALSE)
    metadata <- read.table("${metadata}", header=TRUE, sep="\\t")
    peaks    <- read.table("${union_peaks}", header=FALSE, sep="\\t",
                           col.names=c("chr","start","end"))

    metadata <- metadata[match(colnames(counts), metadata\$sample),]
    metadata\$condition <- factor(metadata\$condition, levels=c("CHD","HFD"))

    dds <- DESeqDataSetFromMatrix(countData=counts, colData=metadata, design=~condition)
    keep <- rowSums(counts(dds)) >= 10
    dds   <- dds[keep,]
    peaks <- peaks[keep,]

    dds <- DESeq(dds)
    res <- results(dds, contrast=c("condition","HFD","CHD"))

    norm_counts <- counts(dds, normalized=TRUE)

    res_df <- as.data.frame(res)
    res_df\$peak_id <- rownames(res_df)
    res_df <- cbind(peaks, res_df)
    write.table(res_df, "deseq2_results.txt", sep="\\t", quote=FALSE, row.names=FALSE)
    write.table(norm_counts, "deseq2_normalized_counts.txt", sep="\\t", quote=FALSE)

    sig <- res_df[!is.na(res_df\$padj) &
                  res_df\$padj < ${params.fdr_threshold} &
                  abs(res_df\$log2FoldChange) > ${params.lfc_threshold},]

    hfd_specific <- sig[sig\$log2FoldChange > 0,]
    chd_specific <- sig[sig\$log2FoldChange < 0,]
    shared <- res_df[is.na(res_df\$padj) |
                     res_df\$padj >= ${params.fdr_threshold} |
                     abs(res_df\$log2FoldChange) <= ${params.lfc_threshold},]

    write.table(sig[,1:3],          "significant_peaks.bed",   sep="\\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    write.table(hfd_specific[,1:3], "HFD_specific_peaks.bed",  sep="\\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    write.table(chd_specific[,1:3], "CHD_specific_peaks.bed",  sep="\\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    write.table(shared[,1:3],       "shared_peaks.bed",        sep="\\t", quote=FALSE, row.names=FALSE, col.names=FALSE)

    pdf("deseq2_plots.pdf", width=10, height=8)
    plotMA(res, main="MA Plot: HFD vs CHD", ylim=c(-5,5))
    plot(res\$log2FoldChange, -log10(res\$pvalue),
         xlab="log2 Fold Change (HFD vs CHD)", ylab="-log10(p-value)",
         main="Volcano: HFD vs CHD",
         pch=20,
         col=ifelse(!is.na(res\$padj) &
                    res\$padj < ${params.fdr_threshold} &
                    abs(res\$log2FoldChange) > ${params.lfc_threshold},
                    "red","grey"))
    abline(h=-log10(0.05), col="blue", lty=2)
    abline(v=c(-${params.lfc_threshold}, ${params.lfc_threshold}), col="blue", lty=2)

    vsd <- vst(dds, blind=FALSE)
    pcaData <- plotPCA(vsd, intgroup="condition", returnData=TRUE)
    pv <- round(100*attr(pcaData,"percentVar"))
    print(ggplot(pcaData, aes(PC1, PC2, color=condition)) +
        geom_point(size=3) +
        xlab(paste0("PC1: ",pv[1],"% var")) +
        ylab(paste0("PC2: ",pv[2],"% var")) +
        ggtitle("PCA of samples") + theme_bw())
    dev.off()

    cat("\\n=== DESeq2 summary ===\\n")
    cat("Total peaks analyzed:", nrow(res_df), "\\n")
    cat("Significant (padj<${params.fdr_threshold}, |LFC|>${params.lfc_threshold}):", nrow(sig), "\\n")
    cat("HFD-specific:", nrow(hfd_specific), "\\n")
    cat("CHD-specific:", nrow(chd_specific), "\\n")
    cat("Shared/background:", nrow(shared), "\\n")
    """
}

/*
 * Resize peaks to 500 bp centered on each peak (for motif analysis).
 * BED files already use chr-prefixed naming, so no extra prefixing step.
 */
process RESIZE_PEAKS {
    tag "${bed_type}"
    publishDir "${params.outdir}/motif_analysis/resized_peaks", mode: 'copy'

    input:
    tuple val(bed_type), path(bed_file)

    output:
    tuple val(bed_type), path("${bed_type}_500bp.bed"), emit: bed

    script:
    """
    awk 'BEGIN{OFS="\\t"} {
        c=int((\$2+\$3)/2);
        s=c-250; e=c+250;
        if (s<0) s=0;
        print \$1, s, e
    }' ${bed_file} > ${bed_type}_500bp.bed
    """
}

/*
 * Download JASPAR 2024 motif database
 */
process DOWNLOAD_JASPAR {
    publishDir "${params.outdir}/motif_analysis/databases", mode: 'copy'

    output:
    path "JASPAR2024_CORE_vertebrates_non-redundant.meme", emit: jaspar

    script:
    """
    wget -O JASPAR2024_CORE_vertebrates_non-redundant.meme \
        'https://jaspar.elixir.no/download/data/2024/CORE/JASPAR2024_CORE_vertebrates_non-redundant_pfms_meme.txt'
    [ -s JASPAR2024_CORE_vertebrates_non-redundant.meme ] || { echo "JASPAR download failed"; exit 1; }
    """
}

/*
 * Extract FASTA for motif analysis (soft-masked)
 */
process EXTRACT_FASTA {
    tag "${bed_type}"
    publishDir "${params.outdir}/motif_analysis/sequences", mode: 'copy'

    input:
    tuple val(bed_type), path(bed_file)
    path genome_fasta

    output:
    tuple val(bed_type), path("${bed_type}.fa"), emit: fasta

    script:
    """
    bedtools getfasta -fi ${genome_fasta} -bed ${bed_file} -fo ${bed_type}.fa
    echo "Extracted \$(grep -c '>' ${bed_type}.fa) sequences for ${bed_type}"
    """
}

/*
 * AME motif enrichment
 */
process RUN_AME {
    tag "${comparison}"
    publishDir "${params.outdir}/motif_analysis/ame_results/${comparison}", mode: 'copy'

    input:
    tuple val(comparison), path(foreground_fasta), path(background_fasta)
    path jaspar_db

    output:
    path "ame.html", emit: html
    path "ame.tsv",  emit: tsv
    path "sequences.tsv", emit: sequences, optional: true

    script:
    """
    # --scoring avg --method ranksum produced degenerate output (every motif
    # showed pos=N, neg=0, p=0) on adipocyte open chromatin where most
    # peaks contain hits for many motifs and rank-sum scores saturate.
    # Switched to totalhits + Fisher exact, which is robust to that case.
    ame --control ${background_fasta} \
        --oc . \
        --scoring totalhits --method fisher \
        --hit-lo-fraction 0.25 \
        --evalue-report-threshold 10 \
        --verbose 1 \
        ${foreground_fasta} ${jaspar_db}
    """
}

/*
 * HOMER findMotifsGenome.pl with shared-peak background
 */
process RUN_HOMER {
    tag "${comparison}"
    publishDir "${params.outdir}/motif_analysis/homer_results/${comparison}", mode: 'copy'

    input:
    tuple val(comparison), path(foreground_bed), path(background_bed)
    path genome_fasta

    output:
    path "homerResults.html", emit: html, optional: true
    path "knownResults.txt", emit: known
    path "homerMotifs.all.motifs", emit: motifs, optional: true
    path "motifFindingParameters.txt", emit: params_file, optional: true

    script:
    """
    findMotifsGenome.pl ${foreground_bed} ${genome_fasta} . \
        -bg ${background_bed} -size 500 -mask -p 4 -len 8,10,12
    """
}

/*
 * Composite motif co-occurrence scan.
 *
 * Tests the sensitization hypothesis: does HFD-opened chromatin contain
 * an enriched fraction of pioneer-factor + glucocorticoid receptor (GR)
 * composite enhancers? Such peaks are candidates for HFD-licensed GR
 * binding sites that could potentiate downstream cortisol signaling.
 *
 * Motifs (JASPAR 2024 IDs):
 *   FOXA1 / FOXA2 - canonical steroid-receptor pioneers
 *   CEBPA / CEBPB - established adipocyte GR pioneers (Madsen 2014;
 *                   Siersbaek 2011)
 *   FOXO1         - direct GR cofactor
 *   NR3C1         - GR itself
 *
 * Outputs a per-peak motif occurrence matrix for each peak class
 * (HFD-specific, CHD-specific, shared) that the qmd consumes for
 * Fisher-exact co-occurrence tests and gene annotation of composite
 * peaks. Peaks with zero motif hits are kept in the output (with
 * zero counts) so denominators are correct in the downstream tests.
 */
process COMPOSITE_MOTIF_SCAN {
    tag "${bed_type}"
    publishDir "${params.outdir}/motif_analysis/composite_scan/${bed_type}", mode: 'copy'

    input:
    tuple val(bed_type), path(fasta)
    path jaspar_db

    output:
    tuple val(bed_type), path("${bed_type}_fimo.tsv"),            emit: fimo
    tuple val(bed_type), path("${bed_type}_per_peak_motifs.tsv"), emit: counts
    path "${bed_type}_motifs_used.txt",                           emit: motifs_used

    script:
    // JASPAR 2024 motif IDs. NR3C1 (GR) is often pruned from JASPAR's
    // "non-redundant" set because its IR3 motif is near-identical to other
    // NR3C/PGR/AR motifs, so we also include PGR (mouse + human) which uses
    // the same IR3 element and is a reliable GR-class proxy. The qmd ORs
    // these signals into a single has_gr classifier.
    def motif_ids = [
        'MA0148.5',  // FOXA1
        'MA0047.5',  // FOXA2
        'MA0466.4',  // CEBPB
        'MA0102.5',  // CEBPA
        'MA0480.3',  // FOXO1
        'MA0113.4',  // NR3C1 (GR) - may not be in non-redundant subset
        'MA2327.1',  // PGR human - GR-class IR3 proxy
        'MA2323.1',  // Pgr mouse - GR-class IR3 proxy
    ]
    def ids_str = motif_ids.join(' ')
    """
    set -e

    # Identify which of the requested motifs actually exist in JASPAR.
    # The MEME 5.5.5 build on this cluster doesn't ship meme-get-motif, so we
    # use awk against the JASPAR file directly (the MEME format is well-defined:
    # each motif starts with a "MOTIF <id> <name>" line).
    found_ids=\$(awk -v wanted="${ids_str}" '
        BEGIN { n=split(wanted, a, " "); for (i=1; i<=n; i++) w[a[i]] = 1 }
        /^MOTIF[ \t]/ && (\$2 in w) { print \$2 }
    ' ${jaspar_db})

    {
        echo "Requested motifs (${motif_ids.size()}): ${ids_str}"
        echo "Found in JASPAR:"
        echo "\$found_ids" | tr ' ' '\\n' | sed 's/^/  /' | grep -v '^\$' || echo "  (none)"
    } > ${bed_type}_motifs_used.txt
    cat ${bed_type}_motifs_used.txt

    if [ -z "\$found_ids" ]; then
        echo "ERROR: none of the requested motifs are in the JASPAR file" >&2
        exit 1
    fi

    # Build --motif flags for FIMO; it accepts repeated --motif <id> to
    # select specific motifs from the input file.
    motif_args=""
    for id in \$found_ids; do
        motif_args="\$motif_args --motif \$id"
    done

    # FIMO scan with only the selected motifs
    fimo \$motif_args \
         --thresh 1e-4 \
         --max-stored-scores 10000000 \
         --oc fimo_out \
         ${jaspar_db} ${fasta}
    cp fimo_out/fimo.tsv ${bed_type}_fimo.tsv

    # FIMO 5.5.x auto-parses FASTA headers shaped like "chr:start-end" and
    # reports matches with sequence_name = chromosome and start/stop in
    # GENOMIC coordinates. We need to map those hits back to the original
    # peaks (one peak per FASTA record), so we reconstruct the peak BED
    # from FASTA headers, convert FIMO output to a hits BED, and use
    # bedtools intersect to associate each motif occurrence with its peak.

    # 1. Peak BED with peak_id (= FASTA header) as the 4th column
    grep '^>' ${fasta} | sed 's/^>//' | \
    awk 'BEGIN{OFS="\\t"} {
        c = index(\$0, ":")
        if (!c) next
        chrom = substr(\$0, 1, c-1)
        rest  = substr(\$0, c+1)
        d = index(rest, "-")
        if (!d) next
        print chrom, substr(rest, 1, d-1), substr(rest, d+1), \$0
    }' > peaks.bed

    # 2. FIMO hits BED (motif_id in column 4). FIMO is 1-based inclusive;
    #    BED is 0-based half-open, so subtract 1 from start.
    tail -n +2 fimo_out/fimo.tsv | grep -v '^#' | grep -v '^\$' | \
    awk -F'\\t' 'BEGIN{OFS="\\t"} NF >= 5 {print \$3, \$4 - 1, \$5, \$1}' > fimo_hits.bed

    # 3. Intersect: keep (peak_id, motif_id) pairs for each motif occurrence
    bedtools intersect -a fimo_hits.bed -b peaks.bed -wa -wb | \
    awk 'BEGIN{OFS="\\t"} {print \$8, \$4}' > peak_motif_pairs.tsv

    # 4. Collapse to per-peak motif counts (zero-hit peaks retained)
    python3 - "${fasta}" peak_motif_pairs.tsv "${bed_type}_per_peak_motifs.tsv" <<'PY'
import sys, collections
fasta_path, pairs_path, out_path = sys.argv[1:4]

# All peak IDs from the FASTA so zero-hit peaks are kept
all_peaks = []
with open(fasta_path) as f:
    for line in f:
        if line.startswith('>'):
            all_peaks.append(line[1:].strip().split()[0])

counts = collections.defaultdict(lambda: collections.Counter())
motifs = set()
with open(pairs_path) as f:
    for line in f:
        cols = line.rstrip('\\n').split('\\t')
        if len(cols) < 2:
            continue
        peak_id, motif_id = cols[0], cols[1]
        counts[peak_id][motif_id] += 1
        motifs.add(motif_id)

motifs = sorted(motifs)
with open(out_path, 'w') as out:
    out.write('peak\\t' + '\\t'.join(motifs) + '\\n')
    for peak in all_peaks:
        c = counts.get(peak, collections.Counter())
        out.write(peak + '\\t' + '\\t'.join(str(c.get(m, 0)) for m in motifs) + '\\n')

n_with_hits = sum(1 for p in counts if any(counts[p].values()))
print(f"Wrote {len(all_peaks)} peaks x {len(motifs)} motifs", file=sys.stderr)
print(f"Peaks with at least one motif hit: {n_with_hits}", file=sys.stderr)
PY
    """
}

/*
 * Full-database motif scan for data-driven sensitizer-TF discovery.
 *
 * Unlike COMPOSITE_MOTIF_SCAN which is hypothesis-driven (tests a curated set
 * of pioneer / cooperator motifs), FULL_MOTIF_SCAN runs FIMO with NO --motif
 * filter against the entire JASPAR file, producing per-peak occurrence counts
 * for all ~600 motifs. The qmd then performs a two-axis ranking:
 *
 *   Axis 1: HFD-specific enrichment relative to CHD-specific
 *           (taken from existing RUN_AME(HFD_vs_CHD) output)
 *   Axis 2: GR-class motif co-occurrence within HFD-specific peaks
 *           (computed in R from this process's per-peak count table)
 *
 * Motifs scoring on both axes are the data-driven sensitizer candidates -
 * TFs that are both HFD-enriched and tend to co-occur with GR.
 *
 * Run only on the smaller peak sets (HFD-specific n~6900, CHD-specific n~1300)
 * to keep compute manageable; we don't need shared-peak full scans for the
 * two-axis analysis.
 */
process FULL_MOTIF_SCAN {
    tag "${bed_type}"
    publishDir "${params.outdir}/motif_analysis/full_motif_scan/${bed_type}", mode: 'copy'

    input:
    tuple val(bed_type), path(fasta)
    path jaspar_db

    output:
    tuple val(bed_type), path("${bed_type}_fimo_all.tsv"),            emit: fimo
    tuple val(bed_type), path("${bed_type}_per_peak_all_motifs.tsv"), emit: counts

    script:
    """
    set -e

    # FIMO with no --motif filter scans every motif in the JASPAR file.
    # --max-stored-scores raised for q-value calculation across many motifs.
    fimo --thresh 1e-4 \
         --max-stored-scores 50000000 \
         --oc fimo_out \
         ${jaspar_db} ${fasta}
    cp fimo_out/fimo.tsv ${bed_type}_fimo_all.tsv

    # As in COMPOSITE_MOTIF_SCAN: reconstruct peak BED from FASTA headers,
    # convert FIMO output to a hits BED, intersect to map genomic-coordinate
    # FIMO hits back to source peaks.
    grep '^>' ${fasta} | sed 's/^>//' | \
    awk 'BEGIN{OFS="\\t"} {
        c = index(\$0, ":")
        if (!c) next
        chrom = substr(\$0, 1, c-1)
        rest  = substr(\$0, c+1)
        d = index(rest, "-")
        if (!d) next
        print chrom, substr(rest, 1, d-1), substr(rest, d+1), \$0
    }' > peaks.bed

    tail -n +2 ${bed_type}_fimo_all.tsv | grep -v '^#' | grep -v '^\$' | \
    awk -F'\\t' 'BEGIN{OFS="\\t"} NF >= 5 {print \$3, \$4 - 1, \$5, \$1}' > fimo_hits.bed

    bedtools intersect -a fimo_hits.bed -b peaks.bed -wa -wb | \
    awk 'BEGIN{OFS="\\t"} {print \$8, \$4}' > peak_motif_pairs.tsv

    python3 - "${fasta}" peak_motif_pairs.tsv "${bed_type}_per_peak_all_motifs.tsv" <<'PY'
import sys, collections
fasta_path, pairs_path, out_path = sys.argv[1:4]

all_peaks = []
with open(fasta_path) as f:
    for line in f:
        if line.startswith('>'):
            all_peaks.append(line[1:].strip().split()[0])

counts = collections.defaultdict(lambda: collections.Counter())
motifs = set()
with open(pairs_path) as f:
    for line in f:
        cols = line.rstrip('\\n').split('\\t')
        if len(cols) < 2:
            continue
        peak_id, motif_id = cols[0], cols[1]
        counts[peak_id][motif_id] += 1
        motifs.add(motif_id)

motifs = sorted(motifs)
with open(out_path, 'w') as out:
    out.write('peak\\t' + '\\t'.join(motifs) + '\\n')
    for peak in all_peaks:
        c = counts.get(peak, collections.Counter())
        out.write(peak + '\\t' + '\\t'.join(str(c.get(m, 0)) for m in motifs) + '\\n')

n_with_hits = sum(1 for p in counts if any(counts[p].values()))
print(f"Wrote {len(all_peaks)} peaks x {len(motifs)} motifs", file=sys.stderr)
print(f"Peaks with at least one motif hit: {n_with_hits}", file=sys.stderr)
PY
    """
}

// ============================================================
// RNA-seq (TRAP) branch processes
// ============================================================

/*
 * Download GENCODE vM25 GTF (last mm10 annotation)
 */
process DOWNLOAD_GTF {
    publishDir "${params.genome_dir}", mode: 'copy'

    output:
    path "gencode.vM25.annotation.gtf", emit: gtf

    script:
    """
    wget -O gencode.vM25.annotation.gtf.gz '${params.gtf_url}'
    gunzip gencode.vM25.annotation.gtf.gz
    [ -s gencode.vM25.annotation.gtf ] || { echo "GTF download empty"; exit 1; }
    echo "GTF lines: \$(wc -l < gencode.vM25.annotation.gtf)"
    """
}

/*
 * Build STAR index (mm10 + GENCODE vM25 splice junctions).
 * Requires ~32 GB RAM; run on a high-memory node.
 * sjdbOverhang = readLength - 1 = 149 for PE150.
 */
process BUILD_STAR_INDEX {
    module 'Bioinformatics:star'
    publishDir "${params.genome_dir}/star_index", mode: 'copy'

    input:
    path genome_fasta
    path gtf

    output:
    path "star_index/", emit: index

    script:
    def threads = task.cpus > 0 ? task.cpus : 4
    """
    mkdir -p star_index
    STAR --runMode genomeGenerate \\
         --genomeDir star_index \\
         --genomeFastaFiles ${genome_fasta} \\
         --sjdbGTFfile ${gtf} \\
         --sjdbOverhang ${params.star_overhang} \\
         --runThreadN ${threads}
    echo "STAR index built"
    """
}

/*
 * Download TRAP-seq FASTQ from SRA (no module needed; fasterq-dump is in
 * the default environment). Kept separate from trimming so the trimgalore
 * module directive does not shadow fasterq-dump in PATH.
 */
process RNASEQ_DOWNLOAD {
    module 'Bioinformatics:sratoolkit/3.1.1'
    tag "${sample.id}"
    publishDir "${params.rnaseq_outdir}/raw/${sample.id}", mode: 'copy',
               pattern: "*.fastq.gz"

    input:
    val sample

    output:
    tuple val(sample.id), val(sample.condition),
          path("${sample.srr}_1.fastq.gz"), path("${sample.srr}_2.fastq.gz"), emit: reads

    script:
    def threads = task.cpus > 0 ? task.cpus : 4
    """
    set -e
    fasterq-dump ${sample.srr} --threads ${threads} --split-files --progress
    gzip ${sample.srr}_1.fastq ${sample.srr}_2.fastq
    echo "Download complete for ${sample.id}"
    """
}

/*
 * Trim adapters from TRAP-seq FASTQs.
 * Trim Galore auto-detects Illumina adapters and trims low-quality ends.
 * Template switching (Maxima H Minus RT) may leave TSO artifact at 5';
 * quality trimming with --length 30 removes most of these.
 */
process RNASEQ_TRIM {
    module 'Bioinformatics:trimgalore'
    tag "${sample_id}"
    publishDir "${params.rnaseq_outdir}/trimmed/${sample_id}", mode: 'copy',
               pattern: "*.{log,txt,html,zip}"

    input:
    tuple val(sample_id), val(condition), path(r1_raw), path(r2_raw)

    output:
    tuple val(sample_id), val(condition),
          path("*_val_1.fq.gz"), path("*_val_2.fq.gz"), emit: reads
    path "*_trimming_report.txt", emit: trim_report

    script:
    def threads = task.cpus > 0 ? task.cpus : 4
    """
    set -e
    trim_galore --paired \\
                --quality 20 \\
                --length 30 \\
                --cores ${threads} \\
                --gzip \\
                ${r1_raw} ${r2_raw}
    echo "Trimming complete for ${sample_id}"
    """
}

/*
 * Align trimmed TRAP-seq reads with STAR.
 * --outFilterMultimapNmax 1 discards multi-mappers (strict unique mapping).
 */
process RNASEQ_ALIGN {
    module 'Bioinformatics:star:samtools/1.21'
    tag "${sample_id}"
    publishDir "${params.rnaseq_outdir}/bam/${sample_id}", mode: 'copy',
               pattern: "*.{bam,bai,log,tab}"

    input:
    tuple val(sample_id), val(condition), path(r1), path(r2)
    path star_index

    output:
    tuple val(sample_id), val(condition),
          path("${sample_id}.Aligned.sortedByCoord.out.bam"),
          path("${sample_id}.Aligned.sortedByCoord.out.bam.bai"), emit: bam
    path "${sample_id}.Log.final.out", emit: align_log

    script:
    def threads = task.cpus > 0 ? task.cpus : 4
    """
    set -e
    STAR --runMode alignReads \\
         --genomeDir ${star_index} \\
         --readFilesIn ${r1} ${r2} \\
         --readFilesCommand zcat \\
         --outSAMtype BAM SortedByCoordinate \\
         --outSAMattributes NH HI AS NM \\
         --outFilterMultimapNmax 1 \\
         --runThreadN ${threads} \\
         --outFileNamePrefix ${sample_id}. \\
         --outBAMsortingThreadN ${threads}

    samtools index ${sample_id}.Aligned.sortedByCoord.out.bam

    echo "=== Alignment summary ${sample_id} ==="
    cat ${sample_id}.Log.final.out
    """
}

/*
 * BigWig tracks from TRAP-seq BAMs (CPM normalised).
 * Uses bedtools genomecov + bedGraphToBigWig (UCSC); no deepTools needed.
 * bedGraphToBigWig is downloaded from UCSC if not already in PATH.
 */
process RNASEQ_BIGWIG {
    tag "${sample_id}"
    publishDir "${params.rnaseq_outdir}/bigwig", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(bam), path(bai)
    path blacklist
    path chrom_sizes

    output:
    tuple val(sample_id), val(condition), path("${sample_id}.CPM.bw"), emit: bigwig

    script:
    """
    set -e

    if command -v bedGraphToBigWig &>/dev/null; then
        BG2BW=bedGraphToBigWig
    else
        wget -q http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v369/bedGraphToBigWig \\
             -O bedGraphToBigWig
        chmod +x bedGraphToBigWig
        BG2BW=./bedGraphToBigWig
    fi

    bedtools intersect -v -abam ${bam} -b ${blacklist} > filtered.bam
    samtools index filtered.bam
    total=\$(samtools view -c -f 2 -F 4 filtered.bam)
    scale=\$(python3 -c "print(1000000.0 / \${total})")

    bedtools genomecov -ibam filtered.bam -bg -pc -scale \${scale} \\
        | sort -k1,1 -k2,2n > ${sample_id}.bedgraph

    \${BG2BW} ${sample_id}.bedgraph ${chrom_sizes} ${sample_id}.CPM.bw

    rm -f filtered.bam filtered.bam.bai ${sample_id}.bedgraph
    echo "BigWig written: ${sample_id}.CPM.bw  (total fragments: \${total})"
    """
}

/*
 * BigWig tracks from ATAC clean BAMs (RPGC normalised).
 * Same bedtools + bedGraphToBigWig approach as RNASEQ_BIGWIG.
 */
process ATAC_BIGWIG {
    tag "${sample_id}"
    publishDir "${params.outdir}/bigwig/atac", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(bam), path(bai)
    path blacklist
    path chrom_sizes

    output:
    tuple val(sample_id), val(condition), path("${sample_id}.RPGC.bw"), emit: bigwig

    script:
    """
    set -e

    if command -v bedGraphToBigWig &>/dev/null; then
        BG2BW=bedGraphToBigWig
    else
        wget -q http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v369/bedGraphToBigWig \\
             -O bedGraphToBigWig
        chmod +x bedGraphToBigWig
        BG2BW=./bedGraphToBigWig
    fi

    bedtools intersect -v -abam ${bam} -b ${blacklist} > filtered.bam
    samtools index filtered.bam
    total=\$(samtools view -c -f 2 -F 4 filtered.bam)
    scale=\$(python3 -c "print(${params.mm10_effective_gs} / \${total})")

    bedtools genomecov -ibam filtered.bam -bg -pc -scale \${scale} \\
        | sort -k1,1 -k2,2n > ${sample_id}.bedgraph

    \${BG2BW} ${sample_id}.bedgraph ${chrom_sizes} ${sample_id}.RPGC.bw

    rm -f filtered.bam filtered.bam.bai ${sample_id}.bedgraph
    echo "BigWig written: ${sample_id}.RPGC.bw  (total fragments: \${total})"
    """
}

/*
 * Gene-level read counting with featureCounts (unstranded, paired-end).
 * Uses GENCODE vM25 GTF; gene_name (symbol) as feature grouping attribute.
 */
process RNASEQ_COUNT_GENES {
    module 'Bioinformatics:subread'
    tag "${sample_id}"
    publishDir "${params.rnaseq_outdir}/counts", mode: 'copy'

    input:
    tuple val(sample_id), val(condition), path(bam), path(bai)
    path gtf

    output:
    tuple val(sample_id), val(condition), path("${sample_id}_gene_counts.txt"), emit: counts
    tuple val(sample_id), path("${sample_id}_gene_counts.txt.summary"), emit: summary

    script:
    def threads = task.cpus > 0 ? task.cpus : 4
    """
    featureCounts \\
        -a ${gtf} \\
        -o ${sample_id}_gene_counts.txt \\
        -p --countReadPairs -B -C \\
        -s 0 \\
        -T ${threads} \\
        -g gene_name \\
        ${bam}
    echo "Counted ${sample_id}: \$(tail -n+3 ${sample_id}_gene_counts.txt | wc -l) genes"
    """
}

/*
 * Merge per-sample featureCounts files into a single count matrix.
 */
process RNASEQ_COMBINE_COUNTS {
    publishDir "${params.rnaseq_outdir}/count_matrix", mode: 'copy'

    input:
    tuple val(sample_ids), val(conditions), path(count_files)

    output:
    path "rnaseq_count_matrix.txt", emit: count_matrix
    path "rnaseq_sample_metadata.txt", emit: metadata

    script:
    """
    #!/usr/bin/env python3
    sample_ids  = "${sample_ids}".strip('[]').split(', ')
    conditions  = "${conditions}".strip('[]').split(', ')
    count_files = "${count_files}".split()

    all_data = {}
    gene_ids = []

    for i, count_file in enumerate(count_files):
        sample_id = sample_ids[i]
        counts = []
        with open(count_file) as f:
            for line in f:
                if line.startswith('#'):
                    continue
                parts = line.strip().split('\\t')
                if parts[0] == 'Geneid':
                    continue
                if i == 0:
                    gene_ids.append(parts[0])
                counts.append(parts[-1])
        all_data[sample_id] = counts

    with open('rnaseq_count_matrix.txt', 'w') as f:
        f.write('Geneid\\t' + '\\t'.join(sample_ids) + '\\n')
        for i, gene_id in enumerate(gene_ids):
            row = [gene_id] + [all_data[s][i] for s in sample_ids]
            f.write('\\t'.join(row) + '\\n')

    with open('rnaseq_sample_metadata.txt', 'w') as f:
        f.write('sample\\tcondition\\n')
        for s, c in zip(sample_ids, conditions):
            f.write(f'{s}\\t{c}\\n')

    print(f"rnaseq_count_matrix.txt: {len(gene_ids)} genes x {len(sample_ids)} samples")
    """
}

/*
 * DESeq2 differential expression (HFD vs CHD) for TRAP-seq.
 *
 * Targeted gene table uses an analytical Normal(0,1) prior on log2FC
 * (conjugate Normal-Normal update on DESeq2 Wald estimates) to compute
 * Bayesian posterior P(HFD > CHD), 95% CrI, and evidence ratio.
 * Equivalent to brms posteriors under the same priors without MCMC overhead.
 *
 * Targeted gene categories:
 *   AP-1 candidates    : Fos Jun Junb Jund Fosl1 Fosl2 Batf Batf3 Atf3 Atf4 Ddit3
 *   VDR pathway        : Vdr Ncoa1 Ncoa2 Ncoa3 Med1
 *   Demoted candidates : Cebpb Cebpa Cebpd Foxa1 Foxa2 Foxo1 Foxo3 Klf13 Prrx1
 *   Artifact check     : Dmrt1 Dmrt2 Dmrt3 Dmrt4
 *   Functional GR tgts : Pnpla2 Hsd11b1 Hsd11b2 Nr3c1 Fkbp5 Sgk1 Tsc22d3 Angptl4 Lep
 */
process RNASEQ_DESEQ2 {
    publishDir "${params.rnaseq_outdir}/deseq2", mode: 'copy'

    input:
    path count_matrix
    path metadata

    output:
    path "rnaseq_deseq2_results.txt",       emit: results
    path "rnaseq_normalized_counts.txt",    emit: norm_counts
    path "rnaseq_targeted_genes.tsv",       emit: targeted
    path "rnaseq_deseq2_plots.pdf",         emit: plots

    script:
    """
    #!/usr/bin/env Rscript
    suppressPackageStartupMessages({
        library(DESeq2)
        library(ggplot2)
    })

    counts   <- read.table("${count_matrix}", header=TRUE, row.names=1,
                           sep="\\t", check.names=FALSE)
    metadata <- read.table("${metadata}", header=TRUE, sep="\\t")
    metadata <- metadata[match(colnames(counts), metadata\$sample), ]
    metadata\$condition <- factor(metadata\$condition, levels=c("CHD","HFD"))

    dds  <- DESeqDataSetFromMatrix(countData=counts, colData=metadata, design=~condition)
    dds  <- dds[rowSums(counts(dds)) >= 10, ]
    dds  <- DESeq(dds)
    res  <- results(dds, contrast=c("condition","HFD","CHD"))

    norm <- counts(dds, normalized=TRUE)
    res_df <- as.data.frame(res)
    write.table(res_df, "rnaseq_deseq2_results.txt",    sep="\\t", quote=FALSE)
    write.table(norm,   "rnaseq_normalized_counts.txt", sep="\\t", quote=FALSE)

    targeted_genes <- c(
        "Fos","Jun","Junb","Jund","Fosl1","Fosl2","Batf","Batf3","Atf3","Atf4","Ddit3",
        "Vdr","Ncoa1","Ncoa2","Ncoa3","Med1",
        "Cebpb","Cebpa","Cebpd","Foxa1","Foxa2","Foxo1","Foxo3","Klf13","Prrx1",
        "Dmrt1","Dmrt2","Dmrt3","Dmrt4",
        "Pnpla2","Hsd11b1","Hsd11b2","Nr3c1","Fkbp5","Sgk1","Tsc22d3","Angptl4","Lep"
    )
    category <- c(
        rep("AP-1", 11), rep("VDR_pathway", 5), rep("demoted", 9),
        rep("artifact_check", 4), rep("GR_target", 9)
    )
    category_map <- setNames(category, targeted_genes)

    tg <- res_df[rownames(res_df) %in% targeted_genes, , drop=FALSE]
    tg\$gene     <- rownames(tg)
    tg\$category <- category_map[tg\$gene]

    chd_cols <- metadata\$sample[metadata\$condition == "CHD"]
    hfd_cols <- metadata\$sample[metadata\$condition == "HFD"]
    tg\$mean_norm_CHD <- rowMeans(norm[tg\$gene, chd_cols, drop=FALSE])
    tg\$mean_norm_HFD <- rowMeans(norm[tg\$gene, hfd_cols, drop=FALSE])
    tg\$detected <- tg\$mean_norm_CHD > 5 | tg\$mean_norm_HFD > 5

    # Analytical Normal(0,1) prior update on DESeq2 Wald estimates
    # Prior: beta ~ N(0,1); Likelihood: LFC | beta ~ N(beta, SE^2)
    # Posterior: beta | data ~ N(mu_post, sigma2_post)
    compute_bayes <- function(lfc, se) {
        sig2_post <- 1 / (1 + 1/se^2)
        mu_post   <- sig2_post * lfc / se^2
        p_hfd_gt  <- pnorm(0, mean=mu_post, sd=sqrt(sig2_post), lower.tail=FALSE)
        er        <- p_hfd_gt / (1 - p_hfd_gt)
        cri_lo    <- qnorm(0.025, mu_post, sqrt(sig2_post))
        cri_hi    <- qnorm(0.975, mu_post, sqrt(sig2_post))
        list(p=p_hfd_gt, er=er, cri_lo=cri_lo, cri_hi=cri_hi)
    }

    tg\$bayes_P_HFD_gt_CHD <- NA_real_
    tg\$bayes_ER            <- NA_real_
    tg\$bayes_CrI_lo        <- NA_real_
    tg\$bayes_CrI_hi        <- NA_real_

    ok <- !is.na(tg\$log2FoldChange) & !is.na(tg\$lfcSE) & tg\$lfcSE > 0
    if (any(ok)) {
        b <- mapply(compute_bayes,
                    tg\$log2FoldChange[ok], tg\$lfcSE[ok], SIMPLIFY=FALSE)
        tg\$bayes_P_HFD_gt_CHD[ok] <- sapply(b, "[[", "p")
        tg\$bayes_ER[ok]            <- sapply(b, "[[", "er")
        tg\$bayes_CrI_lo[ok]        <- sapply(b, "[[", "cri_lo")
        tg\$bayes_CrI_hi[ok]        <- sapply(b, "[[", "cri_hi")
    }

    missing <- setdiff(targeted_genes, rownames(res_df))
    if (length(missing) > 0) {
        miss_df <- data.frame(
            gene=missing, category=category_map[missing],
            baseMean=NA, log2FoldChange=NA, lfcSE=NA,
            stat=NA, pvalue=NA, padj=NA,
            mean_norm_CHD=NA, mean_norm_HFD=NA, detected=FALSE,
            bayes_P_HFD_gt_CHD=NA, bayes_ER=NA, bayes_CrI_lo=NA, bayes_CrI_hi=NA,
            stringsAsFactors=FALSE
        )
        tg <- rbind(tg[, c("gene","category","baseMean","log2FoldChange","lfcSE",
                            "stat","pvalue","padj","mean_norm_CHD","mean_norm_HFD",
                            "detected","bayes_P_HFD_gt_CHD","bayes_ER",
                            "bayes_CrI_lo","bayes_CrI_hi")], miss_df)
    } else {
        tg <- tg[, c("gene","category","baseMean","log2FoldChange","lfcSE",
                     "stat","pvalue","padj","mean_norm_CHD","mean_norm_HFD",
                     "detected","bayes_P_HFD_gt_CHD","bayes_ER","bayes_CrI_lo","bayes_CrI_hi")]
    }
    tg <- tg[order(tg\$category, tg\$gene), ]
    write.table(tg, "rnaseq_targeted_genes.tsv", sep="\\t", quote=FALSE, row.names=FALSE)

    pdf("rnaseq_deseq2_plots.pdf", width=10, height=8)
    plotMA(res, main="MA Plot: HFD vs CHD (TRAP-seq)", ylim=c(-6,6))
    plot(res\$log2FoldChange, -log10(res\$pvalue),
         xlab="log2FC (HFD/CHD)", ylab="-log10(p)",
         main="Volcano: HFD vs CHD TRAP-seq", pch=20,
         col=ifelse(!is.na(res\$padj) & res\$padj < ${params.rnaseq_fdr} &
                    abs(res\$log2FoldChange) > ${params.rnaseq_lfc}, "red","grey60"))
    abline(v=c(-${params.rnaseq_lfc}, ${params.rnaseq_lfc}), h=-log10(0.05),
           lty=2, col="steelblue")
    vsd <- vst(dds, blind=FALSE)
    pd  <- plotPCA(vsd, intgroup="condition", returnData=TRUE)
    pv  <- round(100 * attr(pd,"percentVar"))
    print(ggplot(pd, aes(PC1, PC2, color=condition, label=name)) +
          geom_point(size=3) + geom_text(vjust=-0.8, size=3) +
          xlab(paste0("PC1: ",pv[1],"% var")) + ylab(paste0("PC2: ",pv[2],"% var")) +
          ggtitle("PCA - TRAP-seq samples") + theme_bw())
    tg_ok <- tg[!is.na(tg\$log2FoldChange), ]
    if (nrow(tg_ok) > 0) {
        tg_ok\$label <- paste0(tg_ok\$gene, " (", tg_ok\$category, ")")
        tg_ok <- tg_ok[order(tg_ok\$log2FoldChange), ]
        print(ggplot(tg_ok, aes(x=reorder(label, log2FoldChange), y=log2FoldChange,
                                fill=log2FoldChange > 0)) +
              geom_col() + coord_flip() +
              geom_errorbar(aes(ymin=bayes_CrI_lo, ymax=bayes_CrI_hi), width=0.3) +
              scale_fill_manual(values=c("TRUE"="#d62728","FALSE"="#1f77b4"), name=NULL,
                                labels=c("TRUE"="HFD up","FALSE"="CHD up")) +
              geom_hline(yintercept=0, lty=2) +
              labs(x=NULL, y="log2FC (HFD/CHD)", title="Targeted genes — TRAP-seq") +
              theme_classic(base_size=9))
    }
    dev.off()

    cat("\\n=== TRAP-seq DESeq2 summary ===\\n")
    cat("Genes analyzed:", nrow(res_df), "\\n")
    cat("Sig HFD-up (padj<${params.rnaseq_fdr}, LFC>${params.rnaseq_lfc}):",
        sum(!is.na(res\$padj) & res\$padj<${params.rnaseq_fdr} &
            res\$log2FoldChange>${params.rnaseq_lfc}), "\\n")
    cat("Targeted gene table written to rnaseq_targeted_genes.tsv\\n")
    """
}

/*
 * Main workflow
 */
workflow {
    sra_ch = Channel.from(params.sra_samples)

    DOWNLOAD_GENOME()
    BUILD_BOWTIE2_INDEX(DOWNLOAD_GENOME.out.fasta)
    GENOME_SIZES(DOWNLOAD_GENOME.out.fasta)
    DOWNLOAD_BLACKLIST()

    // Single-emission process outputs are already value channels in modern
    // Nextflow; they can be reused across per-sample invocations directly.
    index_v = BUILD_BOWTIE2_INDEX.out.index.collect()

    // Hinte peaks for concordance check only
    DOWNLOAD_GEO_PEAKS()
    EXTRACT_BED_FILES(DOWNLOAD_GEO_PEAKS.out)

    // Align
    DOWNLOAD_AND_ALIGN(sra_ch, index_v)

    // Filter (dedup, MAPQ, chrM, blacklist)
    FILTER_BAM(DOWNLOAD_AND_ALIGN.out.bam, DOWNLOAD_BLACKLIST.out.bed)

    // MACS2 per sample
    CALL_PEAKS_MACS2(FILTER_BAM.out.bam)

    // Union peaks (post-blacklist)
    CREATE_UNION_PEAKS(
        CALL_PEAKS_MACS2.out.peaks.map { id, cond, p -> p }.collect(),
        DOWNLOAD_BLACKLIST.out.bed
    )

    // Concordance: MACS2 vs Hinte. EXTRACT_BED_FILES already emits a single
    // list of files (path output with glob), so no extra .collect() needed.
    COMPARE_TO_HINTE(
        CALL_PEAKS_MACS2.out.peaks.map { id, cond, p -> p }.collect(),
        EXTRACT_BED_FILES.out.bed_files
    )

    // Count reads in union peaks
    COUNT_PEAKS(FILTER_BAM.out.bam, CREATE_UNION_PEAKS.out.union_saf)

    // ATAC QC: join BAM tuple (id, cond, bam, bai) with summary tuple (id, summary)
    // on sample_id so each task gets a matched pair.
    ATAC_QC(FILTER_BAM.out.bam.join(COUNT_PEAKS.out.summary))

    // Combine counts -> matrix
    COUNT_PEAKS.out.counts
        .map { sample_id, condition, counts_file -> [sample_id, condition, counts_file] }
        .toList()
        .map { list ->
            def sample_ids   = list.collect { it[0] }
            def conditions   = list.collect { it[1] }
            def count_files  = list.collect { it[2] }
            [sample_ids, conditions, count_files]
        }
        .set { combined_counts_ch }
    COMBINE_COUNTS(combined_counts_ch)

    // DESeq2
    DESEQ2_ANALYSIS(
        COMBINE_COUNTS.out.count_matrix,
        COMBINE_COUNTS.out.metadata,
        CREATE_UNION_PEAKS.out.union_peaks
    )

    // Motif analysis: foreground vs background
    DESEQ2_ANALYSIS.out.hfd_peaks
        .map { f -> ['HFD_specific', f] }
        .mix(
            DESEQ2_ANALYSIS.out.chd_peaks.map    { f -> ['CHD_specific', f] },
            DESEQ2_ANALYSIS.out.shared_peaks.map { f -> ['shared',       f] }
        )
        .set { bed_files_ch }

    RESIZE_PEAKS(bed_files_ch)
    DOWNLOAD_JASPAR()
    EXTRACT_FASTA(RESIZE_PEAKS.out.bed, DOWNLOAD_GENOME.out.fasta)

    fasta_map = EXTRACT_FASTA.out.fasta
        .map    { bt, fa -> [bt, fa] }
        .toList()
        .map    { list -> def m=[:]; list.each { bt,fa -> m[bt]=fa }; m }

    ame_comparisons = fasta_map.flatMap { m ->
        [
            ['HFD_vs_CHD',    m['HFD_specific'], m['CHD_specific']],
            ['HFD_vs_shared', m['HFD_specific'], m['shared']],
            ['CHD_vs_shared', m['CHD_specific'], m['shared']]
        ]
    }
    RUN_AME(ame_comparisons, DOWNLOAD_JASPAR.out.jaspar)

    // Pioneer-factor + GR composite-motif scan for sensitization hypothesis.
    // Operates on the same FASTA sets that AME uses (HFD_specific, CHD_specific, shared)
    // and emits per-peak motif occurrence tables for downstream qmd analysis.
    COMPOSITE_MOTIF_SCAN(EXTRACT_FASTA.out.fasta, DOWNLOAD_JASPAR.out.jaspar)

    // Full-database scan for data-driven sensitizer-TF discovery. Run only on
    // condition-specific peak sets (skip shared) - the two-axis ranking only
    // needs HFD-specific and CHD-specific, and shared has 53k peaks which is
    // too slow to scan against 600+ JASPAR motifs.
    EXTRACT_FASTA.out.fasta
        .filter { bt, fa -> bt != 'shared' }
        .set { fasta_non_shared }
    FULL_MOTIF_SCAN(fasta_non_shared, DOWNLOAD_JASPAR.out.jaspar)

    bed_map = RESIZE_PEAKS.out.bed
        .map    { bt, b -> [bt, b] }
        .toList()
        .map    { list -> def m=[:]; list.each { bt,b -> m[bt]=b }; m }

    homer_comparisons = bed_map.flatMap { m ->
        [
            ['HFD_vs_CHD',    m['HFD_specific'], m['CHD_specific']],
            ['HFD_vs_shared', m['HFD_specific'], m['shared']],
            ['CHD_vs_shared', m['CHD_specific'], m['shared']]
        ]
    }
    RUN_HOMER(homer_comparisons, DOWNLOAD_GENOME.out.fasta)

    // ── ATAC BigWig tracks (for paired locus visualization with RNA-seq) ────
    ATAC_BIGWIG(FILTER_BAM.out.bam, DOWNLOAD_BLACKLIST.out.bed, GENOME_SIZES.out.sizes)

    // ── RNA-seq (TRAP) branch ───────────────────────────────────────────────
    DOWNLOAD_GTF()
    BUILD_STAR_INDEX(DOWNLOAD_GENOME.out.fasta, DOWNLOAD_GTF.out.gtf)

    trap_ch = Channel.from(params.trap_samples)
    RNASEQ_DOWNLOAD(trap_ch)
    RNASEQ_TRIM(RNASEQ_DOWNLOAD.out.reads)
    RNASEQ_ALIGN(RNASEQ_TRIM.out.reads, BUILD_STAR_INDEX.out.index)

    RNASEQ_BIGWIG(RNASEQ_ALIGN.out.bam, DOWNLOAD_BLACKLIST.out.bed, GENOME_SIZES.out.sizes)

    RNASEQ_COUNT_GENES(RNASEQ_ALIGN.out.bam, DOWNLOAD_GTF.out.gtf)

    RNASEQ_COUNT_GENES.out.counts
        .map { sample_id, condition, counts_file -> [sample_id, condition, counts_file] }
        .toList()
        .map { list ->
            def sample_ids  = list.collect { it[0] }
            def conditions  = list.collect { it[1] }
            def count_files = list.collect { it[2] }
            [sample_ids, conditions, count_files]
        }
        .set { rnaseq_counts_ch }

    RNASEQ_COMBINE_COUNTS(rnaseq_counts_ch)
    RNASEQ_DESEQ2(
        RNASEQ_COMBINE_COUNTS.out.count_matrix,
        RNASEQ_COMBINE_COUNTS.out.metadata
    )
}

workflow.onComplete {
    log.info """
    Pipeline completed.
    Results: ${params.outdir}
    """
}
