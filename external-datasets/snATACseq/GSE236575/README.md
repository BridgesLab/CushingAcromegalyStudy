# ATAC-seq Differential Peak Analysis Pipeline

## Overview

This Nextflow pipeline performs comprehensive differential chromatin accessibility analysis on ATAC-seq data from the Hinte et al. study (GSE236575), comparing high-fat diet (HFD) versus chow diet (CHD) conditions in mouse adipocytes. The pipeline includes read alignment, peak counting, differential analysis with DESeq2, and transcription factor motif enrichment analysis.

## Study Information

- **GEO Accession**: GSE236575
- **SRA Project**: PRJNA991593
- **Publication**: Hinte et al. (2023)
- **Organism**: Mus musculus (mouse)
- **Cell Type**: Adipocytes isolated using AdipER-Cre/NuTRAP mice
- **Tissue**: Epididymal white adipose tissue (eWAT)
- **Conditions**: 
  - Chow diet (CHD) control - 3 biological replicates
  - High-fat diet (HFD) for 12 weeks - 3 biological replicates

## Samples Analyzed

| Sample ID | SRA Accession | Condition | Description |
|-----------|---------------|-----------|-------------|
| CHD_1     | SRR25146881   | CHD       | Chow diet replicate 1 |
| CHD_2     | SRR25146878   | CHD       | Chow diet replicate 2 |
| CHD_3     | SRR25146873   | CHD       | Chow diet replicate 3 |
| HFD_1     | SRR25146870   | HFD       | High-fat diet replicate 1 |
| HFD_2     | SRR25146875   | HFD       | High-fat diet replicate 2 |
| HFD_3     | SRR25146880   | HFD       | High-fat diet replicate 3 |

## Pipeline Workflow

### 1. Reference Genome Preparation

**Process**: `DOWNLOAD_GENOME` and `BUILD_BOWTIE2_INDEX`

- Downloads mm10 (GRCm38) reference genome from UCSC
- Source: http://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/mm10.fa.gz
- Builds bowtie2 index for read alignment

**Key Parameters**:
- Genome assembly: mm10 (GRCm38)
- Chromosome naming: Uses "chr" prefix (chr1, chr2, etc.)

### 2. Peak File Processing

**Process**: `DOWNLOAD_GEO_PEAKS`, `EXTRACT_BED_FILES`, `CREATE_UNION_PEAKS`

Downloads pre-called peaks from GEO (GSE236575_RAW.tar) containing FDR 0.01% stringent peaks called by the original authors.

**Peak Filtering**:
- Included: Only CHD and HFD samples
- Excluded: LCHD, LHFD, CC, and HC groups (not used in this analysis)
- Mitochondrial peaks removed (chrM)

**Union Peak Set Creation**:
- Combines all peaks from CHD and HFD samples
- Sorts by chromosome and position
- Merges overlapping peaks using bedtools merge
- Creates SAF (Simplified Annotation Format) file for read counting

**Output**: Union peak set containing ~59,587 peaks

### 3. Read Alignment

**Process**: `DOWNLOAD_BAM`

Downloads raw FASTQ files from SRA and aligns to mm10 reference genome.

**Alignment Parameters**:
- Aligner: bowtie2
- Mode: `--very-sensitive` (increased sensitivity for short reads)
- Unmapped reads: Excluded with `--no-unal`
- Paired-end data: Detected automatically

**Quality Control**:
- BAM files sorted and indexed with samtools
- Alignment statistics logged for each sample
- BAM integrity verified with `samtools quickcheck`

**Typical Alignment Statistics**:
- ~73% properly paired reads
- 100% mapped (after filtering with --no-unal)
- ~2% singletons

### 4. Read Counting

**Process**: `COUNT_PEAKS`

Counts reads overlapping each peak in the union peak set using featureCounts.

**Counting Parameters**:
- Format: SAF (Simplified Annotation Format)
- Mode: Paired-end (`-p`)
- Count read pairs: `--countReadPairs`
- Both ends mapped: `-B`
- Chimeric fragments: `-C` (exclude)
- Multimapping: Default (count once)

**Output**: Read count matrix with 59,587 peaks × 6 samples

### 5. Differential Accessibility Analysis

**Process**: `DESEQ2_ANALYSIS`

Performs differential chromatin accessibility analysis using DESeq2.

**Statistical Parameters**:
- Comparison: HFD vs CHD (CHD as reference)
- FDR threshold: 0.05 (5% false discovery rate)
- Log2 fold-change threshold: 1.0 (2-fold change)
- Low count filter: Peaks with total counts ≥ 10 across all samples

**Normalization**:
- Method: DESeq2 median-of-ratios
- Accounts for library size differences between samples

**Statistical Testing**:
- Test: Wald test
- Multiple testing correction: Benjamini-Hochberg (FDR)

**Peak Classification**:
- **HFD-specific peaks**: Significantly increased accessibility in HFD (log2FC > 1, padj < 0.05)
- **CHD-specific peaks**: Significantly decreased accessibility in HFD (log2FC < -1, padj < 0.05)
- **Shared peaks**: Non-significant peaks (padj ≥ 0.05 or |log2FC| ≤ 1.0)

**Outputs**:
- `deseq2_results.txt`: Full results table with statistics for all peaks
- `deseq2_normalized_counts.txt`: Normalized read counts
- `deseq2_plots.pdf`: MA plot, volcano plot, and PCA
- `HFD_specific_peaks.bed`: Peaks with increased accessibility in HFD
- `CHD_specific_peaks.bed`: Peaks with decreased accessibility in HFD  
- `shared_peaks.bed`: Background peaks (non-significant)

### 6. Motif Analysis Preparation

**Processes**: `ADD_CHR_PREFIX`, `RESIZE_PEAKS`, `EXTRACT_FASTA`

Prepares peak regions for motif analysis.

**Peak Processing**:
1. Add "chr" prefix to chromosome names (for genome compatibility)
2. Resize peaks to 500 bp windows centered on peak summit
3. Extract DNA sequences using bedtools getfasta
4. Soft-mask repetitive sequences (lowercase)

**Key Parameters**:
- Window size: 500 bp (250 bp upstream and downstream of center)
- Masking: Soft masking (repeats in lowercase)
- Negative coordinates: Set to 0 if peak extends before chromosome start

### 7. Motif Enrichment Analysis

**Process**: `RUN_AME`

Identifies known transcription factor binding motifs enriched in differential peaks using AME (Analysis of Motif Enrichment) from the MEME Suite.

**Database**:
- Source: JASPAR 2024 CORE vertebrates non-redundant
- URL: https://jaspar.elixir.no/download/data/2024/CORE/
- Format: MEME text format
- Contains: Curated vertebrate transcription factor binding motifs

**AME Parameters**:
- Scoring method: `avg` (average odds score)
- Statistical test: `ranksum` (Wilcoxon rank-sum test)
- Hit fraction threshold: 0.25 (at least 25% of sequences must contain motif)
- E-value threshold: 10 (report motifs with E-value < 10)

**Comparisons Performed**:
1. **HFD_vs_CHD**: HFD-specific peaks vs CHD-specific peaks
2. **HFD_vs_shared**: HFD-specific peaks vs background (shared peaks)
3. **CHD_vs_shared**: CHD-specific peaks vs background (shared peaks)

**Rationale for Multiple Comparisons**:
- Direct comparison (HFD vs CHD) identifies differentially enriched motifs
- Background comparisons identify condition-specific enrichment over constitutive binding

**Outputs**:
- `ame.html`: Interactive HTML report with enriched motifs
- `ame.tsv`: Tab-separated results with statistics
- `sequences.tsv`: Motif matches in sequences

### 8. De Novo Motif Discovery

**Process**: `RUN_HOMER`

Discovers novel and known transcription factor binding motifs using HOMER (Hypergeometric Optimization of Motif EnRichment).

**HOMER Parameters**:
- Motif size: 500 bp windows (centered on peaks)
- Motif lengths: 8, 10, and 12 bp
- Background: Condition-specific (same comparisons as AME)
- Masking: Enabled (excludes repetitive sequences)
- Threads: 4

**Analysis Mode**:
- De novo motif discovery: Enabled (finds novel motifs)
- Known motif enrichment: Enabled (uses HOMER's built-in database)

**Comparisons Performed**:
1. **HFD_vs_CHD**: HFD-specific vs CHD-specific peaks
2. **HFD_vs_shared**: HFD-specific vs background peaks
3. **CHD_vs_shared**: CHD-specific vs background peaks

**Outputs**:
- `homerResults.html`: Visual summary of discovered motifs
- `knownResults.txt`: Enrichment of known motifs
- `homerMotifs.all.motifs`: All discovered motif PWMs
- `motifFindingParameters.txt`: Analysis parameters

## Software Versions

- **Nextflow**: [25.10.0.10289]
- **bowtie2**: [2.4.1]
- **samtools**: [1.21]
- **bedtools**: [2.31.1]
- **featureCounts (subread)**: [2.0.3]
- **R**: [R/4.3.2]
- **DESeq2**: [1.46.0]
- **MEME Suite (AME)**: [5.5.5]
- **HOMER**: [4.11.1]

## Output Directory Structure

```
results/
├── genome/                          # Reference genome files
│   ├── mm10.fa                      # mm10 reference genome
│   └── mm10.*.bt2                   # Bowtie2 index files
├── geo_data/                        # Downloaded GEO data
│   └── GSE236575_RAW.tar
├── bed_files/                       # Extracted peak files
├── peaks/                           # Union peak set
│   ├── union_peaks.bed
│   ├── union_peaks.saf
│   └── peak_stats.txt
├── bam_files/                       # Aligned reads
│   ├── CHD_1/
│   │   ├── SRR25146881.bam
│   │   └── SRR25146881.bam.bai
│   └── [other samples...]
├── counts/                          # Read counts per peak
│   ├── CHD_1_counts.txt
│   └── [other samples...]
├── count_matrix/                    # Combined count matrix
│   ├── count_matrix.txt
│   └── sample_metadata.txt
├── deseq2/                          # Differential analysis results
│   ├── deseq2_results.txt          # Full statistical results
│   ├── deseq2_normalized_counts.txt
│   ├── deseq2_plots.pdf            # MA, volcano, PCA plots
│   ├── significant_peaks.bed       # All significant peaks
│   ├── HFD_specific_peaks.bed      # Increased in HFD
│   ├── CHD_specific_peaks.bed      # Decreased in HFD
│   └── shared_peaks.bed            # Background peaks
└── motif_analysis/
    ├── databases/                   # Motif databases
    │   └── JASPAR2024_CORE_vertebrates_non-redundant.meme
    ├── bed_files/                   # Chr-prefixed BED files
    ├── resized_peaks/               # 500bp centered windows
    ├── sequences/                   # Extracted FASTA sequences
    ├── ame_results/                 # AME motif enrichment
    │   ├── HFD_vs_CHD/
    │   │   ├── ame.html
    │   │   ├── ame.tsv
    │   │   └── sequences.tsv
    │   ├── HFD_vs_shared/
    │   └── CHD_vs_shared/
    └── homer_results/               # HOMER de novo discovery
        ├── HFD_vs_CHD/
        │   ├── homerResults.html
        │   ├── knownResults.txt
        │   └── homerMotifs.all.motifs
        ├── HFD_vs_shared/
        └── CHD_vs_shared/
```

## Key Results Files

### Differential Accessibility

**deseq2_results.txt**: Complete results table with columns:
- `chr`, `start`, `end`: Peak coordinates
- `baseMean`: Mean normalized counts across samples
- `log2FoldChange`: Log2 fold change (HFD vs CHD)
- `lfcSE`: Standard error of log2FC
- `stat`: Wald test statistic
- `pvalue`: Raw p-value
- `padj`: Adjusted p-value (FDR)
- `peak_id`: Unique peak identifier

**Peak BED files**: Can be used for:
- Visualization in genome browsers (IGV, UCSC)
- Overlap analysis with other datasets
- Gene annotation with tools like ChIPseeker or HOMER annotatePeaks.pl

### Motif Analysis

**AME results**: Identifies which known transcription factors are enriched
- Focus on motifs with E-value < 0.05
- Consider biological relevance (e.g., metabolism-related TFs for adipocyte study)

**HOMER results**: Discovers novel motifs and validates known motifs
- De novo motifs may represent poorly characterized TF binding sites
- Compare HOMER known motif results with AME for validation

## Computational Resources

### Minimum Requirements
- CPUs: 8 cores
- Memory: 32 GB RAM
- Storage: 100 GB free space
- Time: ~24-48 hours for complete pipeline

### Process-Specific Resources
- **Genome indexing**: 8 CPUs, 32 GB RAM, ~1 hour
- **Read alignment**: 8 CPUs, 32 GB RAM, ~2-4 hours per sample
- **DESeq2 analysis**: 1 CPU, 16 GB RAM, ~10 minutes
- **HOMER analysis**: 8 CPUs, 32 GB RAM, ~2-4 hours per comparison

## Running the Pipeline

```bash
# Basic execution
nextflow run main.nf

# Resume from cached results
nextflow run main.nf -resume

# With custom parameters
nextflow run main.nf \
  --outdir my_results \
  --fdr_threshold 0.01 \
  --lfc_threshold 1.5
```

## Pipeline Parameters

Modifiable parameters in `main.nf`:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `sra_accession` | PRJNA991593 | SRA project ID |
| `geo_accession` | GSE236575 | GEO series ID |
| `outdir` | results | Output directory |
| `genome_dir` | results/genome | Genome files location |
| `fdr_threshold` | 0.05 | FDR cutoff for significance |
| `lfc_threshold` | 1.0 | Log2 fold-change cutoff |

## Quality Control Considerations

### Alignment Quality
- Check bowtie2 alignment rates in `*_bowtie2.log` files
- Expected: >70% overall alignment rate for ATAC-seq
- Flag samples with <50% alignment rate

### Library Size
- Check total read counts in count matrix
- Large differences (>3-fold) may indicate library prep issues
- DESeq2 normalization accounts for library size

### Sample Clustering
- Examine PCA plot in `deseq2_plots.pdf`
- Samples should cluster by condition
- Outliers may need investigation or removal

### Differential Analysis
- Check dispersion estimates (should be reasonable for ATAC-seq)
- MA plot should show symmetric distribution around log2FC = 0
- Consider biological relevance of differential peaks

## Interpreting Results

### Biological Context
This analysis identifies chromatin regions with differential accessibility between HFD and CHD conditions in adipocytes, which may indicate:
- Changes in transcription factor binding
- Alterations in gene regulatory programs
- Metabolic adaptations to high-fat diet

### Motif Enrichment
Enriched motifs suggest:
- **Transcription factors** whose activity differs between conditions
- **Regulatory pathways** activated/repressed by HFD
- **Potential therapeutic targets** for metabolic disease

### Recommended Follow-up Analyses
1. Gene annotation of differential peaks (nearest genes, genomic features)
2. Pathway enrichment analysis of genes near differential peaks
3. Integration with RNA-seq data from same conditions
4. Validation of key findings with ChIP-seq for specific TFs
5. Functional validation of candidate regulatory regions

## Citation

If you use this pipeline, please cite:

- Original study: Hinte et al., [Publication details]
- DESeq2: Love, Huber, and Anders (2014) Genome Biology
- JASPAR 2024: Castro-Mondragon et al. (2024) Nucleic Acids Research
- MEME Suite: Bailey et al. (2015) Nucleic Acids Research
- HOMER: Heinz et al. (2010) Molecular Cell
- Bowtie2: Langmead and Salzberg (2012) Nature Methods

