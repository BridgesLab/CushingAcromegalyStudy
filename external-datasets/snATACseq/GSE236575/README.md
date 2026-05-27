# ATAC-seq Differential Peak Analysis Pipeline

## Overview

This Nextflow pipeline performs comprehensive differential chromatin accessibility analysis on ATAC-seq data from the Hinte et al. study (GSE236575), comparing high-fat diet (HFD) versus chow diet (CHD) conditions in mouse adipocytes. The pipeline includes read alignment, peak counting, differential analysis with DESeq2, and transcription factor motif enrichment analysis.

## Study Information

- **GEO Accession**: GSE236575
- **SRA Project**: PRJNA991593
- **Publication**: Hinte et al. (2024) PMID 39558077
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

---

## RNA-seq (TRAP) Integration Branch

### Overview

A parallel RNA-seq branch processes **GSE236578 [TRAP]**, the companion
TRAP-seq dataset from the same AdipER-Cre/NuTRAP eWAT adipocytes used for
ATAC-seq (Hinte et al. 2024; PMID 39558077; part of super-series GSE236580).
TRAP-seq captures actively translated transcripts specifically from adipocytes,
avoiding stromal-vascular contamination.

### RNA-seq Samples

| Sample ID | GSM | SRR | Condition |
|-----------|-----|-----|-----------|
| CHD_1 | GSM7558266 | SRR25152278 | Chow diet |
| CHD_2 | GSM7558271 | SRR25152274 | Chow diet |
| CHD_3 | GSM7558276 | SRR25152266 | Chow diet |
| HFD_1 | GSM7558267 | SRR25152277 | High-fat diet |
| HFD_2 | GSM7558272 | SRR25152273 | High-fat diet |
| HFD_3 | GSM7558277 | SRR25152265 | High-fat diet |

Library: PE150, template switching (Maxima H Minus RT), unstranded.

### RNA-seq Pipeline Steps

#### 13. GTF download — `DOWNLOAD_GTF`

Downloads **GENCODE vM25** annotation (last mm10/GRCm38 release) from EBI.
URL: `https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.annotation.gtf.gz`

#### 14. STAR index — `BUILD_STAR_INDEX`

Builds STAR index from mm10 FASTA + GENCODE vM25 GTF.
- `--sjdbOverhang 149` (PE150 − 1)
- Requires ~32 GB RAM; run on a high-memory node.

#### 15. FASTQ download — `RNASEQ_DOWNLOAD`

`fasterq-dump` downloads paired-end FASTQ files from SRA and gzip-compresses them.

#### 15b. Quality trimming — `RNASEQ_TRIM`

Trim Galore paired-end trimming:
- Auto-detects Illumina adapters
- Quality trimming: `--quality 20 --length 30`
- Gzip output

Template-switching libraries (Maxima H Minus RT) may have TSO artifact
bases at the 5' end; quality trimming with `--length 30` removes most.

#### 16. STAR alignment — `RNASEQ_ALIGN`

Paired-end alignment to mm10:
- `--outFilterMultimapNmax 1` — unique mappers only
- Output: coordinate-sorted BAM + `Log.final.out` alignment summary

#### 17. BigWig generation

Both processes use `bedtools genomecov` for coverage calculation and the UCSC
`bedGraphToBigWig` binary to convert bedGraph → BigWig (no deepTools dependency).

- **`RNASEQ_BIGWIG`**: CPM-normalised signal. Scale factor = 1e6 / mapped reads;
  `bedtools genomecov -bg -pc -scale`. Blacklisted regions removed.
  Output: `results/rnaseq/bigwig/<sample_id>.CPM.bw`
- **`ATAC_BIGWIG`**: RPGC-normalised (mm10 effective genome size = 2,494,787,188).
  Scale factor = effectiveGenomeSize / mapped reads; `bedtools genomecov -bg -pc -scale`.
  Blacklisted regions removed.
  Output: `results/bigwig/atac/<sample_id>.RPGC.bw`

Both BigWig sets are produced for locus-track visualization at
Hsd11b1, Fkbp5, Vdr, Junb, Fosl2.

#### 18. Gene quantification — `RNASEQ_COUNT_GENES`

featureCounts gene-level quantification:
- GTF: GENCODE vM25
- Feature grouping: `gene_name`
- Strandness: `-s 0` (unstranded; confirmed for template-switching libraries)
- Paired-end: `-p --countReadPairs -B -C`

#### 19. Count matrix — `RNASEQ_COMBINE_COUNTS`

Python merge of per-sample featureCounts files into `rnaseq_count_matrix.txt`
(same logic as `COMBINE_COUNTS` in the ATAC branch).

#### 20. DESeq2 differential expression — `RNASEQ_DESEQ2`

DESeq2 HFD vs CHD (CHD reference). FDR < 0.05, |LFC| > 0.585 (log2(1.5)).

**Targeted gene table** (`rnaseq_targeted_genes.tsv`): 40 genes across five
categories with log2FC, padj, and Bayesian posterior statistics computed via
analytical Normal(0,1) conjugate update on the DESeq2 Wald estimates:

| Column | Definition |
|--------|------------|
| `bayes_P_HFD_gt_CHD` | Posterior P(β > 0), i.e. P(HFD > CHD) |
| `bayes_ER` | Evidence ratio P(β>0)/P(β<0) |
| `bayes_CrI_lo/hi` | 95% credible interval on log2FC |

These statistics are equivalent to brms posteriors under Normal(0,1) priors
on fixed effects with a Gaussian likelihood from the DESeq2 Wald test.

### RNA-seq Integration Analysis

`rnaseq-integration.qmd` implements:

1. **Dataset confirmation** — sample table and library metadata
2. **Global DE summary** — volcano plot with targeted genes highlighted
3. **Targeted gene table** — all 40 candidates with Bayesian stats and category labels
4. **ATAC × RNA-seq integration** — peak annotation to nearest gene, Fisher
   enrichment test (HFD-up ATAC near HFD-up RNA), motif-class stratification
5. **Decision outputs** — automated verdict for:
   - AP-1 lead (Junb vs Fosl2)
   - DMRT family expression status (artifact verification)
   - Coactivator (NCOA1/2/3, MED1) and HSD11B1 expression status
6. **Fkbp5 AP-1 motif scan** — JASPAR2020 vertebrate PWM scan (746 motifs) across
   the Fkbp5 locus (chr4:99,936,000–100,078,000 mm10); confirms dense Jun-family
   occupancy (542 promoter hits; 4,099 Jun-family hits across the locus)
7. **AP-1 + GR composite peak scan** — classifies every HFD-specific peak and every
   shared (background) peak as AP-1-only / GR-only / both / neither, and tests
   whether the composite AP-1+GR category is enriched in HFD-opened chromatin.
   See [AP-1 + GR composite scan](#ap-1--gr-composite-peak-scan) below for full
   method details.

`expression-barplots.qmd` generates mean ± SE expression barplots (CHD vs HFD)
in TPM for user-defined gene sets. TPM is computed from DESeq2 normalised counts
using union-exon gene lengths derived from TxDb.Mmusculus.UCSC.mm10.knownGene.
Significance stars (DESeq2 Wald test padj) are overlaid on HFD bars.

### New Software Dependencies

| Tool | Version | Use |
|------|---------|-----|
| STAR | 2.7.x | RNA-seq alignment |
| Trim Galore | 0.6.x | Adapter/quality trimming |
| bedGraphToBigWig (UCSC) | static binary | BigWig conversion (downloaded at runtime if not in PATH) |
| wiggletools | 1.2.x | Condition-merged BigWig tracks (optional; shell step in QMD) |

Existing tools (featureCounts, bedtools, DESeq2, R, samtools) are reused from the ATAC branch.

### RNA-seq Output Directory Structure

```
results/
└── rnaseq/
    ├── trimmed/<sample>/       # Trim Galore reports
    ├── bam/<sample>/           # STAR BAMs + alignment logs
    ├── bigwig/                 # <sample_id>.CPM.bw per-sample tracks
    ├── counts/                 # featureCounts per-sample
    ├── count_matrix/           # rnaseq_count_matrix.txt + rnaseq_sample_metadata.txt
    └── deseq2/
        ├── rnaseq_deseq2_results.txt       # Full DE results
        ├── rnaseq_normalized_counts.txt    # DESeq2 normalised counts
        ├── rnaseq_targeted_genes.tsv       # 40-gene targeted table
        └── rnaseq_deseq2_plots.pdf         # MA, volcano, PCA, forest plot

results/bigwig/atac/           # <sample_id>.RPGC.bw ATAC tracks
results/genome/
    ├── gencode.vM25.annotation.gtf        # NEW (GENCODE vM25)
    └── star_index/                        # NEW (STAR mm10 index)
```

---

## AP-1 + GR Composite Peak Scan

### Motivation

The "composite-enhancer" model predicts that HFD-opened chromatin disproportionately
carries **both AP-1 and GR motifs**: AP-1 (led by Junb) acts as a pioneer factor to
open chromatin, licensing glucocorticoid receptor (GR) binding at sites that would
otherwise be inaccessible. Section 7 of `rnaseq-integration.qmd` tests this directly by
classifying peaks into four mutually exclusive categories: AP-1-only, GR-only, both, or
neither, and comparing the distributions between HFD-specific and shared (background) peaks.

### Motif definitions

| Class | Motif IDs (JASPAR 2024) | Rationale |
|-------|------------------------|-----------|
| **AP-1** | 35 motifs: JUN, JUNB, JUND, Jun (MA0488.2, MA0490.3, MA0491.3, MA0492.2, MA0489.3), FOS, FOSL1, FOSL2 (MA0476.2, MA1951.2, MA0477.3, MA0478.2), BATF, BATF3 (MA1634.2, MA0835.3), ATF3 (MA0605.3, MA1988.2), and all pairwise JUN·FOS heterodimer motifs | Core bZIP AP-1 super-family; heterodimers included because Junb/Fos and Junb/Atf3 heterodimers are the likely active complexes |
| **GR-class** | NR3C1 (MA0113.4), Pgr (MA2323.1), PGR (MA2327.1) | NR3C1 is the glucocorticoid receptor; Pgr/PGR share an IR3 half-site biochemically indistinguishable from the GR response element and are included as proxies |

Detection threshold: FIMO p < 1×10⁻⁴ within 500-bp peak windows.

### Input files

| File | Source | Contents |
|------|--------|----------|
| `results/motif_analysis/full_motif_scan/HFD_specific/HFD_specific_per_peak_all_motifs.tsv` | FIMO, all JASPAR 2024 motifs | Per-peak hit counts for all 746 motifs across 6,900 HFD-specific peaks; AP-1 columns extracted by ID |
| `results/motif_analysis/composite_scan/HFD_specific/HFD_specific_per_peak_motifs.tsv` | FIMO, pioneer + GR motifs | Per-peak hit counts for 8 pioneer/GR motifs (FOXA1/2, CEBPA/B, FOXO1, NR3C1, Pgr/PGR) across HFD-specific peaks |
| `results/motif_analysis/composite_scan/shared/shared_per_peak_motifs.tsv` | FIMO, pioneer + GR motifs | Same 8 motifs across 53,397 shared peaks |
| `results/motif_analysis/composite_scan/shared/shared_ap1_per_peak.tsv` | Generated (see below) | Per-peak AP-1 presence (TRUE/FALSE) for shared peaks |

### Generating the shared-peaks AP-1 scan

The full motif scan exists only for HFD-specific peaks. AP-1 presence for shared peaks
must be computed once before rendering:

```bash
# 1. Extract AP-1 motifs from JASPAR 2024 database
python3 - <<'EOF'
import re, sys
motif_ids = set("""MA0099.4 MA0462.3 MA0476.2 MA0477.3 MA0478.2
MA0488.2 MA0489.3 MA0490.3 MA0491.3 MA0492.2
MA0605.3 MA1126.2 MA1127.1 MA1128.2 MA1129.1
MA1130.2 MA1131.2 MA1132.2 MA1133.2 MA1134.2
MA1135.2 MA1136.1 MA1137.2 MA1138.2 MA1139.2
MA1140.3 MA1141.2 MA1142.2 MA1143.2 MA1144.2
MA1145.2 MA1634.2 MA0835.3 MA1951.2 MA1988.2""".split())
DB = "results/motif_analysis/databases/JASPAR2024_CORE_vertebrates_non-redundant.meme"
with open(DB) as f: content = f.read()
header = content[:content.find('\nMOTIF ')]
blocks = re.split(r'(?=\nMOTIF )', content[content.find('\nMOTIF '):])
selected = [b for b in blocks if re.match(r'\nMOTIF (\S+)', b) and
            re.match(r'\nMOTIF (\S+)', b).group(1) in motif_ids]
with open('/tmp/jaspar_ap1.meme', 'w') as out:
    out.write(header)
    for b in selected: out.write(b)
EOF

# 2. Rename FASTA headers so FIMO keeps them intact
#    (FIMO auto-parses chr:start-end as genomic coords, stripping the peak ID)
FA=results/motif_analysis/motif_analysis/sequences/shared.fa
sed 's/^>\(chr[^:]*\):\([0-9]*\)-\([0-9]*\)$/>\1_\2_\3/' $FA > /tmp/shared_renamed.fa

# 3. Run FIMO
fimo --thresh 1e-4 --max-strand --oc /tmp/fimo_shared_ap1 \
     /tmp/jaspar_ap1.meme /tmp/shared_renamed.fa

# 4. Build per-peak presence table in R
Rscript - <<'REOF'
library(tidyverse)
fimo <- read_tsv("/tmp/fimo_shared_ap1/fimo.tsv", comment="#", show_col_types=FALSE) |>
  filter(!is.na(motif_id))
peaks_with_ap1 <- fimo |>
  distinct(sequence_name) |>
  mutate(
    parts = str_split(sequence_name, "_"),
    chr   = map_chr(parts, ~ paste(.x[seq_len(max(1, length(.x)-2))], collapse="_")),
    start = map_chr(parts, ~ .x[length(.x)-1]),
    end   = map_chr(parts, ~ .x[length(.x)]),
    peak  = paste0(chr, ":", start, "-", end)
  ) |> pull(peak)
shared_gr <- read_tsv(
  "results/motif_analysis/composite_scan/shared/shared_per_peak_motifs.tsv",
  show_col_types=FALSE)
write_tsv(
  shared_gr |> select(peak) |> mutate(has_ap1 = peak %in% peaks_with_ap1),
  "results/motif_analysis/composite_scan/shared/shared_ap1_per_peak.tsv"
)
REOF
```

**Note on FASTA files:** Two sets of 500-bp resized peak windows exist with different
centres. The GR composite scan and full motif scan use
`results/motif_analysis/motif_analysis/sequences/` (nested path); the AME/HOMER scans
use `results/motif_analysis/sequences/`. Always use the nested path when adding motif
scans that need to be compared to GR composite scan peak IDs.

### Key results

- **1,526 / 6,900 (22.1%)** HFD-specific peaks carry a GR-class motif.
- AP-1+GR co-occurrence: **9.6% of HFD-specific peaks** vs **7.7% of shared peaks**
  (OR = 1.28, p = 2.3×10⁻⁸, Fisher exact one-sided).
- HFD-specific peaks are AP-1-enriched overall (42.5% AP-1-positive vs 35.6% shared),
  consistent with Junb as the chromatin pioneer at GR-responsive loci.

### Output directory additions

```
results/motif_analysis/composite_scan/
└── shared/
    └── shared_ap1_per_peak.tsv   # peak, has_ap1 (TRUE/FALSE); 53,397 rows
```

---

## Locus-Level ATAC Panels (Sections 6.1a and 8)

### What is shown

`rnaseq-integration.qmd` Section 6.1a and Section 8 plot DESeq2 **normalised ATAC
counts** (mean ± SE, n = 3 per condition) at all peaks within a window around five
key loci. Each peak is a grouped bar (CHD vs HFD). Bar colour indicates whether
the peak is HFD-specific and, if so, its motif content (AP-1+GR / AP-1 / GR / neither).
Significance stars come from the DESeq2 Wald test (padj).

### Data used (no additional downloads required)

| File | Description |
|------|-------------|
| `results/deseq2/deseq2_results.txt` | Peak coordinates + DESeq2 statistics |
| `results/deseq2/deseq2_normalized_counts.txt` | Per-sample normalised read counts |
| `results/motif_analysis/full_motif_scan/HFD_specific/HFD_specific_per_peak_all_motifs.tsv` | AP-1 motif presence per HFD-specific peak |
| `results/motif_analysis/composite_scan/HFD_specific/HFD_specific_per_peak_motifs.tsv` | GR-class motif presence per HFD-specific peak |

### Key locus findings

| Locus | Window (mm10) | Key result |
|-------|--------------|------------|
| Fkbp5 | chr4:99,900,000–100,100,000 | All peaks CHD > HFD; 2 significant — chromatin silencing in HFD |
| Sgk1  | chr10:21,850,000–22,080,000 | 1 HFD-up peak with AP-1+GR motifs (LFC=+1.60) — composite enhancer confirmed |
| Angptl4 | chr17:33,700,000–33,760,000 | No HFD-up peaks in window — GR enhancer is distal |
| Lep | chr6:28,970,000–29,050,000 | No significant ATAC changes |
| Pnpla2 | chr7:141,370,000–141,450,000 | 6/12 peaks significantly CHD-enriched; not chromatin-driven |

---

## BigWig Locus Tracks (Section 9 — requires server BAM files)

Section 9 of `rnaseq-integration.qmd` contains an `eval: false` chunk that will
render true IGV-style locus coverage tracks once BigWig files are available.

### Files needed and where to place them

Copy from the Nextflow pipeline server output (or run `nextflow run main.nf -resume`
from the ATAC BigWig step):

**ATAC-seq BigWigs** (RPGC-normalised, 10 bp bins):
```
results/bigwig/atac/
  CHD_1.RPGC.bw    ← from ATAC BAM results/bam_files/CHD_1/SRR25146881.bam
  CHD_2.RPGC.bw    ← from results/bam_files/CHD_2/SRR25146878.bam
  CHD_3.RPGC.bw    ← from results/bam_files/CHD_3/SRR25146873.bam
  HFD_1.RPGC.bw    ← from results/bam_files/HFD_1/SRR25146870.bam
  HFD_2.RPGC.bw    ← from results/bam_files/HFD_2/SRR25146875.bam
  HFD_3.RPGC.bw    ← from results/bam_files/HFD_3/SRR25146880.bam
```

**RNA-seq BigWigs** (CPM-normalised, 50 bp bins):
```
results/rnaseq/bigwig/
  CHD_1.CPM.bw     ← from RNA BAM results/rnaseq/bam/CHD_1/SRR25152278.bam
  CHD_2.CPM.bw     ← from results/rnaseq/bam/CHD_2/SRR25152274.bam
  CHD_3.CPM.bw     ← from results/rnaseq/bam/CHD_3/SRR25152266.bam
  HFD_1.CPM.bw     ← from results/rnaseq/bam/HFD_1/SRR25152277.bam
  HFD_2.CPM.bw     ← from results/rnaseq/bam/HFD_2/SRR25152273.bam
  HFD_3.CPM.bw     ← from results/rnaseq/bam/HFD_3/SRR25152265.bam
```

If the BigWig files (not the BAMs) were already generated by the pipeline, copy
only the `*.bw` files — they are ~50–200 MB each, far smaller than BAMs.

### Activating the BigWig chunk

Once the files are in place:
1. Open `rnaseq-integration.qmd`
2. Find chunk `bigwig-locus-tracks` (Section 9)
3. Change `#| eval: false` to `#| eval: true`
4. Re-render with `quarto render rnaseq-integration.qmd`

---

## Citation

If you use this pipeline, please cite:

- Original study: Hinte et al. (2024) PMID 39558077
- DESeq2: Love, Huber, and Anders (2014) Genome Biology
- JASPAR 2024: Castro-Mondragon et al. (2024) Nucleic Acids Research
- MEME Suite: Bailey et al. (2015) Nucleic Acids Research
- HOMER: Heinz et al. (2010) Molecular Cell
- Bowtie2: Langmead and Salzberg (2012) Nature Methods
- STAR: Dobin et al. (2013) Bioinformatics
- Trim Galore: Krueger (2023) https://github.com/FelixKrueger/TrimGalore

