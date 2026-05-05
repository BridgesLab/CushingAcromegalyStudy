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
 * Extract Hinte CHD/HFD BED files. Uses an explicit allowlist of sample IDs
 * rather than substring matching so LCHD/LHFD/CC/HC cannot leak through.
 */
process EXTRACT_BED_FILES {
    publishDir "${params.outdir}/bed_files", mode: 'copy'

    input:
    path tar_file

    output:
    path "hinte_*.bed", emit: bed_files
    path "file_list.txt", emit: file_list

    script:
    def keep_ids = params.sra_samples.collect { it.id }.join(' ')
    """
    mkdir -p _all
    tar -xf ${tar_file} -C _all

    > file_list.txt
    for id in ${keep_ids}; do
        # Match files containing the sample ID surrounded by non-alphanumerics
        # (e.g. GSMxxxx_CHD_1_peaks.bed.gz) but NOT LCHD_1, LHFD_1, etc.
        match=\$(ls _all/*.bed.gz 2>/dev/null | grep -E "[^A-Za-z]\${id}[^0-9A-Za-z]" || true)
        if [ -z "\$match" ]; then
            echo "WARNING: no GEO BED matching sample \${id}"
            continue
        fi
        for f in \$match; do
            base=\$(basename "\$f" .bed.gz)
            gunzip -c "\$f" > "hinte_\${id}.bed.tmp"
            # Convert Ensembl-style (1, 2, MT, X, Y) to UCSC-style (chr1, chrM, ...)
            awk 'BEGIN{OFS="\\t"}
                 {
                   c=\$1
                   if (c=="MT") c="chrM"
                   else if (c ~ /^(chr|GL|JH)/) c=c
                   else c="chr"c
                   print c, \$2, \$3
                 }' "hinte_\${id}.bed.tmp" > "hinte_\${id}.bed"
            rm "hinte_\${id}.bed.tmp"
            echo "\${id}\t\$f" >> file_list.txt
        done
    done

    echo "Hinte BED files (chr-normalized):"
    wc -l hinte_*.bed
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
 * Reports per-sample overlap counts and Jaccard.
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
    > concordance_report.txt
    for s in CHD_1 CHD_2 CHD_3 HFD_1 HFD_2 HFD_3; do
        macs="\${s}_peaks.narrowPeak"
        hin="hinte_\${s}.bed"
        if [ ! -s \$macs ] || [ ! -s \$hin ]; then
            echo "MISSING \$macs or \$hin" >> concordance_report.txt
            continue
        fi
        macs_n=\$(wc -l < \$macs)
        hin_n=\$(wc -l < \$hin)
        sort -k1,1 -k2,2n \$macs | cut -f1-3 > _m.bed
        sort -k1,1 -k2,2n \$hin > _h.bed
        overlap=\$(bedtools intersect -u -a _m.bed -b _h.bed | wc -l)
        jacc=\$(bedtools jaccard -a _m.bed -b _h.bed | tail -n1 | awk '{print \$3}')
        bedtools jaccard -a _m.bed -b _h.bed > \${s}_jaccard.txt
        echo -e "\${s}\\tMACS2_peaks:\${macs_n}\\tHinte_peaks:\${hin_n}\\tMACS2_overlapping:\${overlap}\\tJaccard:\${jacc}" >> concordance_report.txt
        rm _m.bed _h.bed
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
    ame --control ${background_fasta} \
        --oc . \
        --scoring avg --method ranksum \
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
 * Main workflow
 */
workflow {
    sra_ch = Channel.from(params.sra_samples)

    DOWNLOAD_GENOME()
    BUILD_BOWTIE2_INDEX(DOWNLOAD_GENOME.out.fasta)
    GENOME_SIZES(DOWNLOAD_GENOME.out.fasta)
    DOWNLOAD_BLACKLIST()

    // Convert single-emission outputs to value channels so they can be reused
    // across all per-sample process invocations.
    blacklist_v = DOWNLOAD_BLACKLIST.out.bed.first()
    genome_v    = DOWNLOAD_GENOME.out.fasta.first()
    index_v     = BUILD_BOWTIE2_INDEX.out.index.collect()

    // Hinte peaks for concordance check only
    DOWNLOAD_GEO_PEAKS()
    EXTRACT_BED_FILES(DOWNLOAD_GEO_PEAKS.out)

    // Align
    DOWNLOAD_AND_ALIGN(sra_ch, index_v)

    // Filter (dedup, MAPQ, chrM, blacklist)
    FILTER_BAM(DOWNLOAD_AND_ALIGN.out.bam, blacklist_v)

    // MACS2 per sample
    CALL_PEAKS_MACS2(FILTER_BAM.out.bam)

    // Union peaks (post-blacklist)
    CREATE_UNION_PEAKS(
        CALL_PEAKS_MACS2.out.peaks.map { id, cond, p -> p }.collect(),
        blacklist_v
    )

    union_saf_v   = CREATE_UNION_PEAKS.out.union_saf.first()
    union_peaks_v = CREATE_UNION_PEAKS.out.union_peaks.first()

    // Concordance: MACS2 vs Hinte. EXTRACT_BED_FILES already emits a single
    // list of files (path output with glob), so no extra .collect() needed.
    COMPARE_TO_HINTE(
        CALL_PEAKS_MACS2.out.peaks.map { id, cond, p -> p }.collect(),
        EXTRACT_BED_FILES.out.bed_files
    )

    // Count reads in union peaks
    COUNT_PEAKS(FILTER_BAM.out.bam, union_saf_v)

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
        union_peaks_v
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
    jaspar_v = DOWNLOAD_JASPAR.out.jaspar.first()
    EXTRACT_FASTA(RESIZE_PEAKS.out.bed, genome_v)

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
    RUN_AME(ame_comparisons, jaspar_v)

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
    RUN_HOMER(homer_comparisons, genome_v)
}

workflow.onComplete {
    log.info """
    Pipeline completed.
    Results: ${params.outdir}
    """
}
