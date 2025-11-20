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

/*
 * Main workflow
 */
workflow {
    // Create channel from SRA samples
    sra_ch = Channel.from(params.sra_samples)
    
    // Download and index genome
    DOWNLOAD_GENOME()
    BUILD_BOWTIE2_INDEX(DOWNLOAD_GENOME.out.fasta)
    
    // Download GEO peak files
    DOWNLOAD_GEO_PEAKS()
    
    // Extract BED files
    EXTRACT_BED_FILES(DOWNLOAD_GEO_PEAKS.out)
    
    // Create union peak set
    CREATE_UNION_PEAKS(EXTRACT_BED_FILES.out.bed_files.collect())
    
    // Download and align BAM files
    DOWNLOAD_BAM(sra_ch, BUILD_BOWTIE2_INDEX.out.index.collect())
    
    // Count reads in peaks
    COUNT_PEAKS(
        DOWNLOAD_BAM.out.bam,
        CREATE_UNION_PEAKS.out.union_saf
    )
    
    // Combine counts - transpose the tuple channel for proper input
    COUNT_PEAKS.out.counts
        .map { sample_id, condition, counts_file -> [sample_id, condition, counts_file] }
        .toList()
        .map { list -> 
            def sample_ids = list.collect { it[0] }
            def conditions = list.collect { it[1] }
            def count_files = list.collect { it[2] }
            [sample_ids, conditions, count_files]
        }
        .set { combined_counts_ch }
    
    COMBINE_COUNTS(combined_counts_ch)
    
    // Run DESeq2
    DESEQ2_ANALYSIS(
        COMBINE_COUNTS.out.count_matrix,
        COMBINE_COUNTS.out.metadata,
        CREATE_UNION_PEAKS.out.union_peaks
    )
    
    // Prepare BED files for motif analysis
    DESEQ2_ANALYSIS.out.hfd_peaks
        .map { file -> ['HFD_specific', file] }
        .mix(
            DESEQ2_ANALYSIS.out.chd_peaks.map { file -> ['CHD_specific', file] },
            DESEQ2_ANALYSIS.out.shared_peaks.map { file -> ['shared', file] }
        )
        .set { bed_files_ch }
    
    // Add chr prefix to BED files
    ADD_CHR_PREFIX(bed_files_ch)
    
    // Resize peaks to 500bp
    RESIZE_PEAKS(ADD_CHR_PREFIX.out.bed)
    
    // Download JASPAR database
    DOWNLOAD_JASPAR()
    
    // Extract FASTA sequences
    EXTRACT_FASTA(
        RESIZE_PEAKS.out.bed,
        DOWNLOAD_GENOME.out.fasta
    )
    
    // Create comparison channels for AME
    // Get the FASTA files by type
    fasta_map = EXTRACT_FASTA.out.fasta
        .map { bed_type, fasta -> [bed_type, fasta] }
        .toList()
        .map { list ->
            def map = [:]
            list.each { bed_type, fasta -> map[bed_type] = fasta }
            map
        }
    
    // Create comparison combinations
    ame_comparisons = fasta_map.flatMap { map ->
        [
            ['HFD_vs_CHD', map['HFD_specific'], map['CHD_specific']],
            ['HFD_vs_shared', map['HFD_specific'], map['shared']],
            ['CHD_vs_shared', map['CHD_specific'], map['shared']]
        ]
    }
    
    // Run AME analyses
    RUN_AME(
        ame_comparisons,
        DOWNLOAD_JASPAR.out.jaspar
    )
    
    // Prepare BED files for HOMER (needs chr-prefixed, resized beds)
    bed_map = RESIZE_PEAKS.out.bed
        .map { bed_type, bed -> [bed_type, bed] }
        .toList()
        .map { list ->
            def map = [:]
            list.each { bed_type, bed -> map[bed_type] = bed }
            map
        }
    
    // Create comparison combinations for HOMER
    homer_comparisons = bed_map.flatMap { map ->
        [
            ['HFD_vs_CHD', map['HFD_specific'], map['CHD_specific']],
            ['HFD_vs_shared', map['HFD_specific'], map['shared']],
            ['CHD_vs_shared', map['CHD_specific'], map['shared']]
        ]
    }
    
    // Run HOMER analyses
    RUN_HOMER(
        homer_comparisons,
        DOWNLOAD_GENOME.out.fasta
    )
}

workflow.onComplete {
    log.info """
    Pipeline completed!
    Results are in: ${params.outdir}
    """
}