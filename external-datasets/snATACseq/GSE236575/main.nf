#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
 * Pipeline for differential ATAC-seq peak analysis
 * Downloads BAM files from SRA and peak files from GEO
 * Performs read counting, DESeq2 analysis, and motif enrichment
 */

params.sra_accession = "PRJNA991593"
params.geo_accession = "GSE236575"
params.outdir = "results"
params.genome_dir = "${params.outdir}/genome"
params.fdr_threshold = 0.05
params.lfc_threshold = 1.0
params.macs2_qvalue  = 0.01
params.mapq_threshold = 30
params.blacklist_url = "https://github.com/Boyle-Lab/Blacklist/raw/master/lists/mm10-blacklist.v2.bed.gz"

// ── RNA-seq (TRAP) branch — GSE236578 ──────────────────────────────────────
// Translating Ribosome Affinity Purification (TRAP) from the same
// AdipER-Cre/NuTRAP eWAT adipocytes used for ATAC-seq (Hinte et al. 2024).
// Library: paired-end 150 bp, template switching (Maxima H Minus RT),
// unstranded. Matched 3×CHD + 3×HFD; weight-loss arms excluded.
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

// ── ATAC BigWig parameters ──────────────────────────────────────────────────
// Effective genome size for mm10 RPGC normalization (excludes N's; standard value)
params.mm10_effective_gs = 2494787188

// SRA sample information - HFD and CHD samples only
params.sra_samples = [
    // CHD samples (Chow Diet)
    [id: 'CHD_1', srr: 'SRR25146881', condition: 'CHD'],
    [id: 'CHD_2', srr: 'SRR25146878', condition: 'CHD'],
    [id: 'CHD_3', srr: 'SRR25146873', condition: 'CHD'],
    
    // HFD samples (High Fat Diet)
    [id: 'HFD_1', srr: 'SRR25146870', condition: 'HFD'],
    [id: 'HFD_2', srr: 'SRR25146875', condition: 'HFD'],
    [id: 'HFD_3', srr: 'SRR25146880', condition: 'HFD']
]

log.info """
    =========================================
    ATAC-seq Differential Peak Analysis
    =========================================
    SRA Project    : ${params.sra_accession}
    GEO Accession  : ${params.geo_accession}
    Output dir     : ${params.outdir}
    FDR threshold  : ${params.fdr_threshold}
    LFC threshold  : ${params.lfc_threshold}
    =========================================
    """
    .stripIndent()

/*
 * Download mm10 genome
 */
process DOWNLOAD_GENOME {
    publishDir "${params.genome_dir}", mode: 'copy'
    
    output:
    path "mm10.fa", emit: fasta
    
    script:
    """
    echo "Downloading mm10 genome from UCSC..."
    wget -O mm10.fa.gz http://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/mm10.fa.gz
    
    echo "Uncompressing genome..."
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
    path "mm10.fa", emit: fasta
    
    script:
    """
    echo "Building bowtie2 index for mm10..."
    bowtie2-build --threads ${task.cpus} ${fasta} mm10
    
    echo "Bowtie2 index build complete"
    """
}

/*
 * Generate chromosome sizes from mm10 FASTA (required by bedGraphToBigWig)
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
 * Download GEO raw data containing peak files
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
 * Extract and filter BED files from GEO archive
 */
process EXTRACT_BED_FILES {
    publishDir "${params.outdir}/bed_files", mode: 'copy'
    
    input:
    path tar_file
    
    output:
    path "*.bed.gz", emit: bed_files
    path "file_list.txt", emit: file_list
    
    script:
    """
    tar -xf ${tar_file}
    
    # Find only CHD and HFD bed files (exclude LHFD, LCHD, CC, HC)
    ls *.bed.gz | grep -E '(CHD|HFD)' | grep -v -E '(LHFD|LCHD|CC|HC)' > file_list.txt
    
    # Keep only the filtered files
    cat file_list.txt | while read file; do
        echo "Keeping: \$file"
    done
    
    # Remove unwanted files
    ls *.bed.gz | grep -v -E '(CHD|HFD)' | xargs rm -f || true
    ls *.bed.gz | grep -E '(LHFD|LCHD|CC|HC)' | xargs rm -f || true
    """
}

/*
 * Create union peak set from all CHD and HFD samples
 */
process CREATE_UNION_PEAKS {
    publishDir "${params.outdir}/peaks", mode: 'copy'
    
    input:
    path bed_files
    
    output:
    path "union_peaks.bed", emit: union_peaks
    path "union_peaks.saf", emit: union_saf
    path "peak_stats.txt", emit: stats
    
    script:
    """
    # Combine all bed files, sort, and merge
    gunzip -c *.bed.gz | \
        sort -k1,1 -k2,2n | \
        bedtools merge -i - > union_peaks.bed
    
    # Remove mitochondrial peaks
    grep -v "chrM" union_peaks.bed > union_peaks_tmp.bed
    mv union_peaks_tmp.bed union_peaks.bed
    
    # Create SAF format for featureCounts
    awk 'BEGIN{OFS="\\t"} {print "peak_"NR, \$1, \$2, \$3, "+"}' union_peaks.bed > union_peaks.saf
    
    # Generate statistics
    echo "Total union peaks: \$(wc -l < union_peaks.bed)" > peak_stats.txt
    echo "Total genomic coverage: \$(awk '{sum+=\$3-\$2} END{print sum}' union_peaks.bed) bp" >> peak_stats.txt
    """
}

/*
 * Download FASTQ and align with bowtie2
 */
process DOWNLOAD_BAM {
    tag "${sample.id}"
    publishDir "${params.outdir}/bam_files/${sample.id}", mode: 'copy'
    
    input:
    val sample
    path bowtie2_index
    
    output:
    tuple val(sample.id), val(sample.condition), path("${sample.srr}.bam"), path("${sample.srr}.bam.bai"), emit: bam
    
    script:
    def threads = task.cpus > 0 ? task.cpus : 1
    """
    set -e
    
    echo "Downloading ${sample.srr}..."
    
    # Download using fasterq-dump
    fasterq-dump ${sample.srr} --threads ${threads} --split-files --progress
    
    # Check if paired-end or single-end
    if [ -f ${sample.srr}_2.fastq ]; then
        echo "Paired-end data detected"
        FASTQ1="${sample.srr}_1.fastq"
        FASTQ2="${sample.srr}_2.fastq"
        
        echo "Aligning paired-end reads with bowtie2..."
        bowtie2 -x mm10 \
            -1 \${FASTQ1} \
            -2 \${FASTQ2} \
            -p ${threads} \
            --very-sensitive \
            --no-unal \
            2> ${sample.srr}_bowtie2.log | \
            samtools view -bS -o ${sample.srr}_unsorted.bam -
    else
        echo "Single-end data detected"
        FASTQ="${sample.srr}.fastq"
        
        echo "Aligning single-end reads with bowtie2..."
        bowtie2 -x mm10 \
            -U \${FASTQ} \
            -p ${threads} \
            --very-sensitive \
            --no-unal \
            2> ${sample.srr}_bowtie2.log | \
            samtools view -bS -o ${sample.srr}_unsorted.bam -
    fi
    
    # Sort BAM
    echo "Sorting BAM..."
    samtools sort -@ ${threads} -m 800M -o ${sample.srr}.bam ${sample.srr}_unsorted.bam
    
    # Clean up intermediate files
    rm -f ${sample.srr}*.fastq ${sample.srr}_unsorted.bam
    
    # Index the BAM file
    echo "Indexing BAM..."
    samtools index ${sample.srr}.bam
    
    # Verify BAM file
    echo "Verifying BAM..."
    samtools quickcheck ${sample.srr}.bam
    
    # Print alignment stats
    echo "Alignment statistics:"
    cat ${sample.srr}_bowtie2.log
    
    echo "Successfully processed ${sample.srr}"
    """
}

/*
 * Count reads in peaks using featureCounts
 */
process COUNT_PEAKS {
    tag "${sample_id}"
    publishDir "${params.outdir}/counts", mode: 'copy'
    
    input:
    tuple val(sample_id), val(condition), path(bam), path(bai)
    path saf
    
    output:
    tuple val(sample_id), val(condition), path("${sample_id}_counts.txt"), emit: counts
    path "${sample_id}_counts.txt.summary", emit: summary
    
    script:
    def threads = task.cpus > 0 ? task.cpus : 1
    """
    featureCounts \
        -F SAF \
        -a ${saf} \
        -o ${sample_id}_counts.txt \
        -p \
        --countReadPairs \
        -B \
        -C \
        -T ${threads} \
        ${bam}
    """
}

/*
 * Combine all count files and create count matrix
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
    import csv
    import sys
    
    # Parse the input tuples
    sample_ids = "${sample_ids}".strip('[]').split(', ')
    conditions = "${conditions}".strip('[]').split(', ')
    count_files = "${count_files}".split()
    
    print(f"Processing {len(count_files)} samples...")
    print(f"Samples: {sample_ids}")
    print(f"Conditions: {conditions}")
    
    # Read all count files and store data
    all_data = {}
    gene_ids = []
    
    for i, count_file in enumerate(count_files):
        sample_id = sample_ids[i]
        print(f"Reading {count_file} for sample {sample_id}...")
        
        counts = []
        with open(count_file, 'r') as f:
            for line in f:
                # Skip comment lines
                if line.startswith('#'):
                    continue
                
                parts = line.strip().split('\\t')
                
                # Skip header line
                if parts[0] == 'Geneid':
                    continue
                
                # Store gene_id from first file
                if i == 0:
                    gene_ids.append(parts[0])
                
                # Get count (last column)
                counts.append(parts[-1])
        
        all_data[sample_id] = counts
    
    print(f"Read {len(gene_ids)} peaks")
    
    # Write count matrix
    with open('count_matrix.txt', 'w') as f:
        # Write header
        f.write('Geneid\\t' + '\\t'.join(sample_ids) + '\\n')
        
        # Write data rows
        for i, gene_id in enumerate(gene_ids):
            row = [gene_id] + [all_data[sample_id][i] for sample_id in sample_ids]
            f.write('\\t'.join(row) + '\\n')
    
    # Write metadata file
    with open('sample_metadata.txt', 'w') as f:
        f.write('sample\\tcondition\\n')
        for sample_id, condition in zip(sample_ids, conditions):
            f.write(f'{sample_id}\\t{condition}\\n')
    
    print(f"Created count matrix with {len(gene_ids)} peaks and {len(sample_ids)} samples")
    print("Done!")
    """
}

/*
 * Run DESeq2 analysis
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
    
    library(DESeq2)
    library(ggplot2)
    
    # Read data
    counts <- read.table("${count_matrix}", header=TRUE, row.names=1, sep="\\t")
    metadata <- read.table("${metadata}", header=TRUE, sep="\\t")
    peaks <- read.table("${union_peaks}", header=FALSE, sep="\\t")
    colnames(peaks) <- c("chr", "start", "end")
    
    # Ensure metadata order matches counts
    metadata <- metadata[match(colnames(counts), metadata\$sample),]
    metadata\$condition <- factor(metadata\$condition, levels=c("CHD", "HFD"))
    
    # Create DESeq2 object
    dds <- DESeqDataSetFromMatrix(
        countData = counts,
        colData = metadata,
        design = ~ condition
    )
    
    # Filter low count peaks
    keep <- rowSums(counts(dds)) >= 10
    dds <- dds[keep,]
    peaks <- peaks[keep,]
    
    # Run DESeq2
    dds <- DESeq(dds)
    res <- results(dds, contrast=c("condition", "HFD", "CHD"))
    
    # Get normalized counts
    norm_counts <- counts(dds, normalized=TRUE)
    
    # Save results
    res_df <- as.data.frame(res)
    res_df\$peak_id <- rownames(res_df)
    res_df <- cbind(peaks, res_df)
    write.table(res_df, "deseq2_results.txt", sep="\\t", quote=FALSE, row.names=FALSE)
    write.table(norm_counts, "deseq2_normalized_counts.txt", sep="\\t", quote=FALSE)
    
    # Identify significant peaks
    sig <- res_df[!is.na(res_df\$padj) & res_df\$padj < ${params.fdr_threshold} & 
                  abs(res_df\$log2FoldChange) > ${params.lfc_threshold},]
    
    hfd_specific <- sig[sig\$log2FoldChange > 0,]
    chd_specific <- sig[sig\$log2FoldChange < 0,]
    
    # Save BED files
    write.table(sig[,1:3], "significant_peaks.bed", sep="\\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    write.table(hfd_specific[,1:3], "HFD_specific_peaks.bed", sep="\\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    write.table(chd_specific[,1:3], "CHD_specific_peaks.bed", sep="\\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    
    # Create shared peaks (non-significant)
    shared <- res_df[is.na(res_df\$padj) | res_df\$padj >= ${params.fdr_threshold} | abs(res_df\$log2FoldChange) <= ${params.lfc_threshold},]
    write.table(shared[,1:3], "shared_peaks.bed", sep="\\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    
    # Generate plots
    pdf("deseq2_plots.pdf", width=10, height=8)
    
    # MA plot
    plotMA(res, main="MA Plot: HFD vs CHD", ylim=c(-5,5))
    
    # Volcano plot
    plot(res\$log2FoldChange, -log10(res\$pvalue),
         xlab="log2 Fold Change", ylab="-log10(p-value)",
         main="Volcano Plot: HFD vs CHD",
         pch=20, col=ifelse(res\$padj < ${params.fdr_threshold} & 
                           abs(res\$log2FoldChange) > ${params.lfc_threshold}, 
                           "red", "grey"))
    abline(h=-log10(0.05), col="blue", lty=2)
    abline(v=c(-${params.lfc_threshold}, ${params.lfc_threshold}), col="blue", lty=2)
    
    # PCA plot
    vsd <- vst(dds, blind=FALSE)
    pcaData <- plotPCA(vsd, intgroup="condition", returnData=TRUE)
    percentVar <- round(100 * attr(pcaData, "percentVar"))
    
    ggplot(pcaData, aes(PC1, PC2, color=condition)) +
        geom_point(size=3) +
        xlab(paste0("PC1: ",percentVar[1],"% variance")) +
        ylab(paste0("PC2: ",percentVar[2],"% variance")) +
        ggtitle("PCA of Samples") +
        theme_bw()
    
    dev.off()
    
    # Print summary
    cat("\\n=== DESeq2 Analysis Summary ===\\n")
    cat("Total peaks analyzed:", nrow(res_df), "\\n")
    cat("Significant peaks (padj < ${params.fdr_threshold}, |LFC| > ${params.lfc_threshold}):", nrow(sig), "\\n")
    cat("HFD-specific peaks (increased accessibility):", nrow(hfd_specific), "\\n")
    cat("CHD-specific peaks (decreased accessibility):", nrow(chd_specific), "\\n")
    cat("Shared/background peaks:", nrow(shared), "\\n")
    """
}

/*
 * Add chr prefix to BED files for genome compatibility
 */
process ADD_CHR_PREFIX {
    tag "${bed_type}"
    publishDir "${params.outdir}/motif_analysis/bed_files", mode: 'copy'
    
    input:
    tuple val(bed_type), path(bed_file)
    
    output:
    tuple val(bed_type), path("${bed_type}_chr.bed"), emit: bed
    
    script:
    """
    # Add chr prefix to chromosome names
    awk 'BEGIN{OFS="\\t"} {print "chr"\$1, \$2, \$3}' ${bed_file} > ${bed_type}_chr.bed
    """
}

/*
 * Resize peaks to 500bp windows centered on peak
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
    # Resize to 500bp centered windows
    awk 'BEGIN{OFS="\\t"} {
        center=int((\$2+\$3)/2); 
        start=center-250; 
        end=center+250;
        if(start<0) start=0;
        print \$1, start, end
    }' ${bed_file} > ${bed_type}_500bp.bed
    """
}

/*
 * Download JASPAR motif database
 */
process DOWNLOAD_JASPAR {
    publishDir "${params.outdir}/motif_analysis/databases", mode: 'copy'
    
    output:
    path "JASPAR2024_CORE_vertebrates_non-redundant.meme", emit: jaspar
    
    script:
    """
    echo "Downloading JASPAR 2024 vertebrates motif database..."
    wget -O JASPAR2024_CORE_vertebrates_non-redundant.meme \
        'https://jaspar.elixir.no/download/data/2024/CORE/JASPAR2024_CORE_vertebrates_non-redundant_pfms_meme.txt'
    
    # Verify download
    if [ ! -s JASPAR2024_CORE_vertebrates_non-redundant.meme ]; then
        echo "ERROR: Failed to download JASPAR database"
        exit 1
    fi
    
    echo "JASPAR database downloaded successfully"
    wc -l JASPAR2024_CORE_vertebrates_non-redundant.meme
    """
}

/*
 * Extract FASTA sequences from BED regions
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
    # Extract sequences and mask repeats
    bedtools getfasta -fi ${genome_fasta} -bed ${bed_file} -fo ${bed_type}_unmasked.fa
    
    # Soft-mask repeats (convert to lowercase)
    bedtools maskfasta -soft -fi ${bed_type}_unmasked.fa -bed ${bed_file} -fo ${bed_type}.fa 2>/dev/null || cp ${bed_type}_unmasked.fa ${bed_type}.fa
    
    rm ${bed_type}_unmasked.fa
    
    echo "Extracted \$(grep -c '>' ${bed_type}.fa) sequences for ${bed_type}"
    """
}

/*
 * Run AME motif enrichment analysis
 */
process RUN_AME {
    tag "${comparison}"
    publishDir "${params.outdir}/motif_analysis/ame_results/${comparison}", mode: 'copy'
    
    input:
    tuple val(comparison), path(foreground_fasta), path(background_fasta)
    path jaspar_db
    
    output:
    path "ame.html", emit: html
    path "ame.tsv", emit: tsv
    path "sequences.tsv", emit: sequences, optional: true
    
    script:
    """
    ame --control ${background_fasta} \
        --oc . \
        --scoring avg \
        --method ranksum \
        --hit-lo-fraction 0.25 \
        --evalue-report-threshold 10 \
        --verbose 1 \
        ${foreground_fasta} \
        ${jaspar_db}
    
    echo "AME analysis complete for ${comparison}"
    """
}

/*
 * Run HOMER motif analysis
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
    # Run HOMER findMotifsGenome.pl - without -nomotif to generate full results
    findMotifsGenome.pl \
        ${foreground_bed} \
        ${genome_fasta} \
        . \
        -bg ${background_bed} \
        -size 500 \
        -mask \
        -p 4 \
        -len 8,10,12
    
    echo "HOMER analysis complete for ${comparison}"
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
 * Download TRAP-seq FASTQ and trim adapters.
 * Trim Galore auto-detects Illumina adapters and trims low-quality ends.
 * Template switching (Maxima H Minus RT) may leave TSO artifact at 5';
 * quality trimming with --length 30 removes most of these.
 */
process RNASEQ_DOWNLOAD_AND_TRIM {
    module 'Bioinformatics:trimgalore'
    tag "${sample.id}"
    publishDir "${params.rnaseq_outdir}/trimmed/${sample.id}", mode: 'copy',
               pattern: "*.{log,txt,html,zip}"

    input:
    val sample

    output:
    tuple val(sample.id), val(sample.condition),
          path("${sample.srr}_1_val_1.fq.gz"), path("${sample.srr}_2_val_2.fq.gz"), emit: reads
    path "*_trimming_report.txt", emit: trim_report

    script:
    def threads = task.cpus > 0 ? task.cpus : 4
    """
    set -e
    fasterq-dump ${sample.srr} --threads ${threads} --split-files --progress

    # Trim Galore: auto-detect adapters, quality trim, paired-end
    trim_galore --paired \\
                --quality 20 \\
                --length 30 \\
                --cores ${threads} \\
                --gzip \\
                ${sample.srr}_1.fastq ${sample.srr}_2.fastq

    rm -f ${sample.srr}_1.fastq ${sample.srr}_2.fastq
    echo "Trimming complete for ${sample.id}"
    """
}

/*
 * Align trimmed TRAP-seq reads with STAR.
 * Output: coordinate-sorted BAM + alignment summary log.
 * --outFilterMultimapNmax 1 discards multi-mappers (strict unique mapping).
 */
process RNASEQ_ALIGN {
    module 'Bioinformatics:star'
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
 * BigWig tracks from TRAP-seq BAMs for locus visualization.
 * CPM normalization via bedtools genomecov + bedGraphToBigWig (UCSC).
 * bedGraphToBigWig is downloaded from UCSC if not in PATH.
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

    # bedGraphToBigWig: use from PATH or download UCSC static binary
    if command -v bedGraphToBigWig &>/dev/null; then
        BG2BW=bedGraphToBigWig
    else
        wget -q http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v369/bedGraphToBigWig \\
             -O bedGraphToBigWig
        chmod +x bedGraphToBigWig
        BG2BW=./bedGraphToBigWig
    fi

    # Remove blacklist reads, then count properly paired fragments
    bedtools intersect -v -abam ${bam} -b ${blacklist} > filtered.bam
    samtools index filtered.bam
    total=\$(samtools view -c -f 2 -F 4 filtered.bam)

    # CPM scale: 1e6 / total_fragments
    scale=\$(python3 -c "print(1000000.0 / \${total})")

    # Genome coverage (paired-end fragments, CPM scaled)
    bedtools genomecov -ibam filtered.bam -bg -pc -scale \${scale} \\
        | sort -k1,1 -k2,2n > ${sample_id}.bedgraph

    \${BG2BW} ${sample_id}.bedgraph ${chrom_sizes} ${sample_id}.CPM.bw

    rm -f filtered.bam filtered.bam.bai ${sample_id}.bedgraph
    echo "BigWig written: ${sample_id}.CPM.bw  (total fragments: \${total})"
    """
}

/*
 * BigWig tracks from ATAC BAMs for locus visualization.
 * RPGC normalization (reads per genomic content) via bedtools genomecov
 * + bedGraphToBigWig (UCSC). Effective genome size: mm10 = 2,494,787,188.
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

    # Remove blacklist reads
    bedtools intersect -v -abam ${bam} -b ${blacklist} > filtered.bam
    samtools index filtered.bam
    total=\$(samtools view -c -f 2 -F 4 filtered.bam)

    # RPGC scale: effective_genome_size / total_fragments
    scale=\$(python3 -c "print(${params.mm10_effective_gs} / \${total})")

    bedtools genomecov -ibam filtered.bam -bg -pc -scale \${scale} \\
        | sort -k1,1 -k2,2n > ${sample_id}.bedgraph

    \${BG2BW} ${sample_id}.bedgraph ${chrom_sizes} ${sample_id}.RPGC.bw

    rm -f filtered.bam filtered.bam.bai ${sample_id}.bedgraph
    echo "BigWig written: ${sample_id}.RPGC.bw  (total fragments: \${total})"
    """
}

/*
 * Download ENCODE mm10 blacklist (used by BigWig processes above and by
 * the ATAC filtering; if the ATAC branch already ran, Nextflow caching
 * will reuse the result via the shared output path).
 */
process DOWNLOAD_BLACKLIST {
    publishDir "${params.outdir}/blacklist", mode: 'copy'

    output:
    path "mm10-blacklist.v2.bed", emit: bed

    script:
    """
    wget -O mm10-blacklist.v2.bed.gz '${params.blacklist_url}'
    gunzip mm10-blacklist.v2.bed.gz
    [ -s mm10-blacklist.v2.bed ] || { echo "Blacklist empty"; exit 1; }
    echo "Blacklist regions: \$(wc -l < mm10-blacklist.v2.bed)"
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
 * This is equivalent to what brms would return under the same priors
 * without the MCMC overhead, and is exact given the Gaussian likelihood
 * implied by the DESeq2 Wald test.
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

    # ── Targeted gene table ──────────────────────────────────────────────────
    targeted_genes <- c(
        # AP-1
        "Fos","Jun","Junb","Jund","Fosl1","Fosl2","Batf","Batf3","Atf3","Atf4","Ddit3",
        # VDR pathway
        "Vdr","Ncoa1","Ncoa2","Ncoa3","Med1",
        # Demoted candidates (verification)
        "Cebpb","Cebpa","Cebpd","Foxa1","Foxa2","Foxo1","Foxo3","Klf13","Prrx1",
        # Artifact check
        "Dmrt1","Dmrt2","Dmrt3","Dmrt4",
        # Functional GR targets
        "Pnpla2","Hsd11b1","Hsd11b2","Nr3c1","Fkbp5","Sgk1","Tsc22d3","Angptl4","Lep"
    )
    # Assign category labels
    category <- c(
        rep("AP-1", 11), rep("VDR_pathway", 5), rep("demoted", 9),
        rep("artifact_check", 4), rep("GR_target", 9)
    )
    category_map <- setNames(category, targeted_genes)

    tg <- res_df[rownames(res_df) %in% targeted_genes, , drop=FALSE]
    tg\$gene     <- rownames(tg)
    tg\$category <- category_map[tg\$gene]

    # Add mean normalized counts per condition for context
    chd_cols <- metadata\$sample[metadata\$condition == "CHD"]
    hfd_cols <- metadata\$sample[metadata\$condition == "HFD"]
    chd_norm <- norm[tg\$gene, chd_cols, drop=FALSE]
    hfd_norm <- norm[tg\$gene, hfd_cols, drop=FALSE]
    tg\$mean_norm_CHD <- rowMeans(chd_norm)
    tg\$mean_norm_HFD <- rowMeans(hfd_norm)
    tg\$detected <- tg\$mean_norm_CHD > 5 | tg\$mean_norm_HFD > 5

    # ── Analytical Bayesian update: Normal(0,1) prior on log2FC ─────────────
    # Likelihood: LFC | beta ~ N(beta, SE^2)  (DESeq2 Wald estimate)
    # Prior:      beta ~ N(0, 1)
    # Posterior:  beta | data ~ N(mu_post, sigma2_post)
    #   1/sigma2_post = 1 + 1/SE^2
    #   mu_post       = sigma2_post * LFC / SE^2
    compute_bayes <- function(lfc, se) {
        sig2_post <- 1 / (1 + 1/se^2)
        mu_post   <- sig2_post * lfc / se^2
        p_hfd_gt  <- pnorm(0, mean=mu_post, sd=sqrt(sig2_post), lower.tail=FALSE)
        er        <- p_hfd_gt / (1 - p_hfd_gt)
        cri_lo    <- qnorm(0.025, mu_post, sqrt(sig2_post))
        cri_hi    <- qnorm(0.975, mu_post, sqrt(sig2_post))
        list(p=p_hfd_gt, er=er, cri_lo=cri_lo, cri_hi=cri_hi)
    }

    # Only compute where we have valid LFC and SE
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

    # Genes not detected in counts matrix
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

    # ── Diagnostic plots ─────────────────────────────────────────────────────
    pdf("rnaseq_deseq2_plots.pdf", width=10, height=8)

    # MA plot
    plotMA(res, main="MA Plot: HFD vs CHD (TRAP-seq)", ylim=c(-6,6))

    # Volcano
    plot(res\$log2FoldChange, -log10(res\$pvalue),
         xlab="log2FC (HFD/CHD)", ylab="-log10(p)",
         main="Volcano: HFD vs CHD TRAP-seq",
         pch=20, col=ifelse(!is.na(res\$padj) &
                            res\$padj < ${params.rnaseq_fdr} &
                            abs(res\$log2FoldChange) > ${params.rnaseq_lfc},
                            "red","grey60"))
    abline(v=c(-${params.rnaseq_lfc}, ${params.rnaseq_lfc}), h=-log10(0.05),
           lty=2, col="steelblue")

    # PCA
    vsd <- vst(dds, blind=FALSE)
    pd  <- plotPCA(vsd, intgroup="condition", returnData=TRUE)
    pv  <- round(100 * attr(pd,"percentVar"))
    print(ggplot(pd, aes(PC1, PC2, color=condition, label=name)) +
          ggplot2::geom_point(size=3) +
          ggplot2::geom_text(vjust=-0.8, size=3) +
          xlab(paste0("PC1: ",pv[1],"% var")) +
          ylab(paste0("PC2: ",pv[2],"% var")) +
          ggtitle("PCA - TRAP-seq samples") +
          theme_bw())

    # Targeted gene heatmap of log2FC
    tg_ok <- tg[!is.na(tg\$log2FoldChange), ]
    if (nrow(tg_ok) > 0) {
        tg_ok\$label <- paste0(tg_ok\$gene, " (", tg_ok\$category, ")")
        tg_ok <- tg_ok[order(tg_ok\$log2FoldChange), ]
        print(ggplot(tg_ok, aes(x=reorder(label, log2FoldChange), y=log2FoldChange,
                                fill=log2FoldChange > 0)) +
              geom_col() +
              coord_flip() +
              geom_errorbar(aes(ymin=bayes_CrI_lo, ymax=bayes_CrI_hi), width=0.3) +
              scale_fill_manual(values=c("TRUE"="#d62728","FALSE"="#1f77b4"),
                                labels=c("TRUE"="HFD up","FALSE"="CHD up"),
                                name=NULL) +
              geom_hline(yintercept=0, lty=2) +
              labs(x=NULL, y="log2FC (HFD/CHD)", title="Targeted genes — TRAP-seq") +
              theme_classic(base_size=9))
    }

    dev.off()

    cat("\\n=== TRAP-seq DESeq2 summary ===\\n")
    cat("Genes analyzed:", nrow(res_df), "\\n")
    cat("Sig HFD-up (padj<${params.rnaseq_fdr}, LFC>${params.rnaseq_lfc}):",
        sum(!is.na(res\$padj) & res\$padj<${params.rnaseq_fdr} & res\$log2FoldChange>${params.rnaseq_lfc}),
        "\\n")
    cat("Sig HFD-down:", sum(!is.na(res\$padj) & res\$padj<${params.rnaseq_fdr} & res\$log2FoldChange < -${params.rnaseq_lfc}), "\\n")
    cat("\\nTargeted gene table (", nrow(tg), "genes) written to rnaseq_targeted_genes.tsv\\n")
    """
}

/*
 * Main workflow
 */
workflow {

    // ── Shared reference resources ──────────────────────────────────────────
    DOWNLOAD_GENOME()
    BUILD_BOWTIE2_INDEX(DOWNLOAD_GENOME.out.fasta)
    GENOME_SIZES(DOWNLOAD_GENOME.out.fasta)
    DOWNLOAD_GTF()
    DOWNLOAD_BLACKLIST()

    // ── ATAC-seq branch ─────────────────────────────────────────────────────
    sra_ch = Channel.from(params.sra_samples)

    DOWNLOAD_GEO_PEAKS()
    EXTRACT_BED_FILES(DOWNLOAD_GEO_PEAKS.out)
    CREATE_UNION_PEAKS(EXTRACT_BED_FILES.out.bed_files.collect())

    DOWNLOAD_BAM(sra_ch, BUILD_BOWTIE2_INDEX.out.index.collect())

    // ATAC BigWig tracks for locus visualization
    ATAC_BIGWIG(DOWNLOAD_BAM.out.bam, DOWNLOAD_BLACKLIST.out.bed, GENOME_SIZES.out.sizes)

    COUNT_PEAKS(DOWNLOAD_BAM.out.bam, CREATE_UNION_PEAKS.out.union_saf)

    COUNT_PEAKS.out.counts
        .map { sample_id, condition, counts_file -> [sample_id, condition, counts_file] }
        .toList()
        .map { list ->
            def sample_ids  = list.collect { it[0] }
            def conditions  = list.collect { it[1] }
            def count_files = list.collect { it[2] }
            [sample_ids, conditions, count_files]
        }
        .set { combined_counts_ch }

    COMBINE_COUNTS(combined_counts_ch)
    DESEQ2_ANALYSIS(
        COMBINE_COUNTS.out.count_matrix,
        COMBINE_COUNTS.out.metadata,
        CREATE_UNION_PEAKS.out.union_peaks
    )

    DESEQ2_ANALYSIS.out.hfd_peaks
        .map { file -> ['HFD_specific', file] }
        .mix(
            DESEQ2_ANALYSIS.out.chd_peaks.map  { file -> ['CHD_specific', file] },
            DESEQ2_ANALYSIS.out.shared_peaks.map { file -> ['shared', file] }
        )
        .set { bed_files_ch }

    ADD_CHR_PREFIX(bed_files_ch)
    RESIZE_PEAKS(ADD_CHR_PREFIX.out.bed)
    DOWNLOAD_JASPAR()

    EXTRACT_FASTA(RESIZE_PEAKS.out.bed, DOWNLOAD_GENOME.out.fasta)

    fasta_map = EXTRACT_FASTA.out.fasta
        .map { bed_type, fasta -> [bed_type, fasta] }
        .toList()
        .map { list -> def m=[:]; list.each { bt,fa -> m[bt]=fa }; m }

    ame_comparisons = fasta_map.flatMap { m ->
        [
            ['HFD_vs_CHD',    m['HFD_specific'], m['CHD_specific']],
            ['HFD_vs_shared', m['HFD_specific'], m['shared']],
            ['CHD_vs_shared', m['CHD_specific'], m['shared']]
        ]
    }
    RUN_AME(ame_comparisons, DOWNLOAD_JASPAR.out.jaspar)

    bed_map = RESIZE_PEAKS.out.bed
        .map { bed_type, bed -> [bed_type, bed] }
        .toList()
        .map { list -> def m=[:]; list.each { bt,b -> m[bt]=b }; m }

    homer_comparisons = bed_map.flatMap { m ->
        [
            ['HFD_vs_CHD',    m['HFD_specific'], m['CHD_specific']],
            ['HFD_vs_shared', m['HFD_specific'], m['shared']],
            ['CHD_vs_shared', m['CHD_specific'], m['shared']]
        ]
    }
    RUN_HOMER(homer_comparisons, DOWNLOAD_GENOME.out.fasta)

    // ── RNA-seq (TRAP) branch ───────────────────────────────────────────────
    BUILD_STAR_INDEX(DOWNLOAD_GENOME.out.fasta, DOWNLOAD_GTF.out.gtf)

    trap_ch = Channel.from(params.trap_samples)
    RNASEQ_DOWNLOAD_AND_TRIM(trap_ch)
    RNASEQ_ALIGN(RNASEQ_DOWNLOAD_AND_TRIM.out.reads, BUILD_STAR_INDEX.out.index)

    // BigWig tracks for locus visualization
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
    Pipeline completed!
    Results are in: ${params.outdir}
    """
}