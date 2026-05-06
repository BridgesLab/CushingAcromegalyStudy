# ATAC-seq Differential Peak Analysis Pipeline

## Overview

Nextflow pipeline for differential chromatin accessibility analysis on the Hinte et al. (2023) ATAC-seq dataset (GSE236575), comparing high-fat diet (HFD) vs chow diet (CHD) mouse adipocytes. The pipeline aligns reads de novo, performs ATAC-specific BAM cleanup (deduplication, MAPQ filtering, mitochondrial-read removal, ENCODE blacklist filtering), calls peaks with MACS2, runs DESeq2 differential analysis, and runs AME and HOMER motif enrichment.

The pipeline does **not** rely on Hinte's pre-called peaks for analysis. The authors' BED files are still downloaded but are used only as a concordance check against our re-called MACS2 peaks.

## Study Information

- **GEO Accession**: GSE236575
- **SRA Project**: PRJNA991593
- **Publication**: Hinte et al. (2023)
- **Organism**: Mus musculus (mouse)
- **Cell Type**: Adipocytes isolated using AdipER-Cre/NuTRAP mice
- **Tissue**: Epididymal white adipose tissue (eWAT)
- **Conditions used here**:
  - Chow diet (CHD) control - 3 biological replicates
  - High-fat diet (HFD) for 12 weeks - 3 biological replicates
- **Conditions excluded**: LCHD, LHFD (weight-loss arms), CC, HC (other comparison arms not used in this analysis)

## Samples Analyzed

| Sample ID | SRA Accession | Condition | Description |
|-----------|---------------|-----------|-------------|
| CHD_1     | SRR25146881   | CHD       | Chow diet replicate 1 |
| CHD_2     | SRR25146878   | CHD       | Chow diet replicate 2 |
| CHD_3     | SRR25146873   | CHD       | Chow diet replicate 3 |
| HFD_1     | SRR25146870   | HFD       | High-fat diet replicate 1 |
| HFD_2     | SRR25146875   | HFD       | High-fat diet replicate 2 |
| HFD_3     | SRR25146880   | HFD       | High-fat diet replicate 3 |

## Conventions

- **Genome build**: mm10 (GRCm38). UCSC release from `hgdownload.soe.ucsc.edu`.
- **Chromosome naming**: UCSC-style `chr1, chr2, …, chrM, chrX, chrY` end-to-end.
  Hinte's GEO BED files use Ensembl-style naming (`1, 2, …, MT, X, Y`); the
  `EXTRACT_BED_FILES` process normalizes them (`MT → chrM`, prefix `chr` to numeric/X/Y).
- **Liftover**: Not currently applied. If integrating with mm9 datasets (e.g.
  Soccio 2015), apply `liftOver` with the `mm9ToMm10.over.chain.gz` chain file
  before overlap and record the chain version alongside the lifted file.

## Pipeline Workflow

### 1. Reference genome and indexing

**Processes**: `DOWNLOAD_GENOME`, `BUILD_BOWTIE2_INDEX`, `GENOME_SIZES`

- mm10 reference downloaded from UCSC (chr-prefixed)
- bowtie2 index built for alignment
- `samtools faidx` produces `mm10.chrom.sizes`

### 2. ENCODE blacklist

**Process**: `DOWNLOAD_BLACKLIST`

Downloads the **mm10 blacklist v2** from the Boyle Lab (chr-prefixed BED). Applied at two points:
1. BAM filtering (reads overlapping blacklist removed)
2. Peak filtering (union peaks intersecting blacklist removed)

URL: `https://github.com/Boyle-Lab/Blacklist/raw/master/lists/mm10-blacklist.v2.bed.gz`

### 3. Hinte pre-called peaks (concordance only)

**Processes**: `DOWNLOAD_GEO_PEAKS`, `EXTRACT_BED_FILES`

Downloads `GSE236575_RAW.tar` from GEO. The included BED files were called by the authors at "FDR 0.01% stringent" (peak-caller and exact parameters: see Hinte et al. 2023 Methods). These are **not** used for the differential analysis here — only for the `COMPARE_TO_HINTE` concordance check.

GEO supplementary filename conventions are unreliable across studies, so the filter uses substring matching: keep filenames containing `CHD` or `HFD`, exclude `LCHD`, `LHFD`, `CC`, `HC` (other arms of the study). All replicates within a condition are then merged into `hinte_CHD.bed` / `hinte_HFD.bed` — concordance is computed per condition rather than per replicate, which avoids needing to parse replicate numbers out of arbitrary filenames. Chromosome names are normalized to UCSC form on extraction. The full list of input files used is recorded in `bed_files/file_list.txt`.

### 4. Read alignment

**Process**: `DOWNLOAD_AND_ALIGN`

Downloads FASTQ from SRA via `fasterq-dump` and aligns to mm10 with bowtie2 using ATAC-appropriate parameters.

**Parameters**:
- `--very-sensitive` — increased sensitivity
- `-X 2000` — allow long fragments common in ATAC libraries
- `--no-mixed --no-discordant` — only properly paired alignments

### 5. ATAC BAM filtering

**Process**: `FILTER_BAM`

Standard ATAC post-alignment cleanup. All steps are logged per sample in `bam_files/<sample>/<sample>.filter_stats.txt`.

1. **Flag filter**: `samtools view -f 2 -F 1804 -q 30` — properly paired, primary, mapped, MAPQ ≥ 30
2. **Duplicate removal**: `samtools fixmate` → coord-sort → `samtools markdup -r`
3. **Mitochondrial reads removed**: chromosome list is taken from the BAM header itself, with `chrM` and `MT` excluded — naming-agnostic
4. **Blacklist removal**: `bedtools intersect -v -abam` against ENCODE mm10 v2 blacklist

Output: `<sample>.clean.bam` (indexed).

### 6. Peak calling (MACS2)

**Process**: `CALL_PEAKS_MACS2`

Per-sample narrow peak calling on cleaned BAMs.

**Parameters**:
- `-f BAMPE` — paired-end mode (uses fragment ends directly; no `--shift`/`--extsize` needed)
- `-g mm` — mouse genome size
- `-q 0.01` — matches Hinte's stated stringency
- `--nomodel --keep-dup all` — duplicates already removed in `FILTER_BAM`

### 7. Union peak set

**Process**: `CREATE_UNION_PEAKS`

- Concatenate all 6 sample `narrowPeak` files
- Defensive `chrM`/`MT` filter
- Sort + `bedtools merge`
- `bedtools intersect -v` against blacklist (defense in depth)
- Generate SAF for featureCounts
- `peak_stats.txt` reports total count, total bp coverage, per-chromosome counts

### 8. Concordance with Hinte

**Process**: `COMPARE_TO_HINTE`

Two levels of comparison:

1. **Per-sample**: each of the 6 MACS2 sample peak sets vs the matching condition's merged Hinte set (`hinte_CHD.bed` or `hinte_HFD.bed`).
2. **Per-condition**: the union of all MACS2 peaks for a condition (all 3 reps merged) vs the matching merged Hinte set.

Each comparison reports MACS2 peak count, Hinte peak count, number of MACS2 peaks overlapping a Hinte peak, and bedtools Jaccard index.

Output: `hinte_concordance/concordance_report.txt` plus per-sample / per-condition `*_jaccard.txt`.

Concordance lets you decide whether MACS2 stringency matches Hinte's well enough for downstream comparisons; large divergence is a flag to revisit MACS2 settings.

#### Interpreting the report — Jaccard vs overlap rate

The two columns answer different questions and can disagree dramatically. **Use the overlap rate, not the Jaccard, to judge whether the peak sets agree on locations.**

- **`MACS2_overlapping / MACS2_peaks`** — fraction of our peaks that fall inside any Hinte peak. This is the biologically meaningful concordance metric.
- **`Jaccard`** — `intersection_bp / union_bp`. This is dominated by *peak width*, not by location agreement. A narrow peak sitting entirely inside a broader one contributes a Jaccard equal to (narrow width / broad width), even though location agreement is perfect.

In our run (May 2026), per-sample overlap rates were 97–99% but Jaccard was 0.07–0.14. The reason is a peak-width mismatch:

| metric | MACS2 (ours) | Hinte (per-condition merged) | ratio |
|---|---|---|---|
| n peaks | 61,619 (union) | 52,385 (CHD) / 54,778 (HFD) | ~1.2 |
| median width | 835 bp | 3,906 bp | 4.7x |
| p90 width | 1,498 bp | 11,781 bp | 7.9x |

Hinte's GEO BEDs are kilobase-scale regions (likely either MACS2 `--broad` mode, an HMM-based caller like HMMRATAC/Genrich, or post-call merging/extension), and the per-condition merge of 3 replicates widens them further. Our MACS2 narrowPeaks are higher-resolution, which is **preferred** for downstream motif enrichment (AME/HOMER) and overlap with reference ChIP-seq peaks (Soccio, Hu, etc.). Just be aware of the width difference if comparing peak counts/widths to Hinte's published numbers.

To check peak widths yourself:
```bash
awk '{print $3-$2}' results/peaks/union_peaks.bed | sort -n | \
  awk 'BEGIN{c=0;s=0}{a[c++]=$1;s+=$1}END{print "n="c,"median="a[int(c/2)],"mean="s/c,"p90="a[int(c*0.9)]}'
awk '{print $3-$2}' results/bed_files/hinte_CHD.bed | sort -n | \
  awk 'BEGIN{c=0;s=0}{a[c++]=$1;s+=$1}END{print "n="c,"median="a[int(c/2)],"mean="s/c,"p90="a[int(c*0.9)]}'
```

### 9. Read counting

**Process**: `COUNT_PEAKS`

featureCounts on the union SAF (paired-end, both ends mapped, exclude chimeric).

### 10. ATAC QC

**Process**: `ATAC_QC`

Per-sample QC, joined to BAMs by sample ID:
- `<sample>_qc.txt`: clean read count, reads in peaks, FRiP
- `<sample>_fragsize.txt`: fragment-size distribution (TLEN > 0, < 2000 bp)

Healthy ATAC libraries typically show FRiP > 0.2 and a clear nucleosome-free vs mono-nucleosome periodicity in fragment size.

### 11. Differential accessibility

**Process**: `DESEQ2_ANALYSIS`

DESeq2, HFD vs CHD (CHD as reference).

- FDR threshold: 0.05 (`params.fdr_threshold`)
- |Log2FC| threshold: 1.0 (`params.lfc_threshold`)
- Pre-filter: peaks with total counts ≥ 10 across all samples
- Median-of-ratios normalization, Wald test, BH correction

Output BED files (chr-prefixed throughout):
- `HFD_specific_peaks.bed` — significantly more accessible in HFD
- `CHD_specific_peaks.bed` — significantly more accessible in CHD
- `shared_peaks.bed` — non-significant background peaks
- `significant_peaks.bed` — union of HFD- and CHD-specific
- `deseq2_results.txt`, `deseq2_normalized_counts.txt`, `deseq2_plots.pdf`

### 12. Motif analysis

**Processes**: `RESIZE_PEAKS`, `DOWNLOAD_JASPAR`, `EXTRACT_FASTA`, `RUN_AME`, `RUN_HOMER`

- Peaks resized to 500 bp centered on each peak
- AME (MEME Suite) against JASPAR 2024 CORE vertebrate non-redundant motifs
- HOMER `findMotifsGenome.pl` for de novo + known motif enrichment

Comparisons:
1. `HFD_vs_CHD` — HFD-specific (foreground) vs CHD-specific (background)
2. `HFD_vs_shared` — HFD-specific vs background (constitutive)
3. `CHD_vs_shared` — CHD-specific vs background (constitutive)

The `shared_peaks.bed` background preserves accessibility bias — i.e. enrichment is over the full open-chromatin universe, not over the genome.

## Software Versions

- Nextflow: 25.10.0.10289
- bowtie2: 2.4.x
- samtools: 1.21
- bedtools: 2.31.1
- MACS2: 2.2.x
- featureCounts (subread): 2.0.3
- R: 4.3.2
- DESeq2: 1.46.0
- MEME Suite (AME): 5.5.5
- HOMER: 4.11.1

## Output Directory Structure

```
results/
├── genome/                          # mm10 reference + bowtie2 index + chrom.sizes
├── blacklist/                       # ENCODE mm10 blacklist v2
├── geo_data/                        # Hinte's GSE236575_RAW.tar (concordance only)
├── bed_files/                       # Hinte BEDs, chr-normalized (concordance only)
├── bam_files/<sample>/              # Per-sample raw + clean BAMs and filter stats
│   ├── <sample>.raw.bam[.bai]
│   ├── <sample>.clean.bam[.bai]
│   ├── <sample>.filter_stats.txt
│   └── <sample>_bowtie2.log
├── macs2_peaks/<sample>/            # Per-sample MACS2 narrowPeak output
├── peaks/                           # Union peak set
│   ├── union_peaks.bed
│   ├── union_peaks.saf
│   └── peak_stats.txt
├── hinte_concordance/
│   ├── concordance_report.txt
│   └── *_jaccard.txt
├── counts/                          # featureCounts per sample
├── count_matrix/                    # Combined count matrix + sample metadata
├── qc/                              # FRiP + fragment-size distributions
├── deseq2/                          # Differential accessibility results
└── motif_analysis/
    ├── databases/                   # JASPAR 2024
    ├── resized_peaks/               # 500-bp centered windows
    ├── sequences/                   # FASTA per peak set
    ├── ame_results/{HFD_vs_CHD,HFD_vs_shared,CHD_vs_shared}/
    └── homer_results/{HFD_vs_CHD,HFD_vs_shared,CHD_vs_shared}/
```

## Pipeline Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `sra_accession`      | PRJNA991593 | SRA project ID |
| `geo_accession`      | GSE236575   | GEO series ID |
| `outdir`             | results     | Output directory |
| `genome_dir`         | results/genome | Genome files location |
| `fdr_threshold`      | 0.05        | DESeq2 FDR cutoff |
| `lfc_threshold`      | 1.0         | DESeq2 |Log2FC| cutoff |
| `macs2_qvalue`       | 0.01        | MACS2 q-value cutoff (matches Hinte's stringency) |
| `mapq_threshold`     | 30          | Post-alignment MAPQ filter |
| `blacklist_url`      | Boyle Lab mm10 v2 | ENCODE blacklist |

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
  --lfc_threshold 1.5 \
  --macs2_qvalue 0.05
```

## Quality Control Checklist

Before treating any output as a preliminary figure:

- **Alignment rate** (`*_bowtie2.log`): >70% expected for ATAC.
- **Filter stats** (`<sample>.filter_stats.txt`): mitochondrial fraction is typically 20–80% in mouse adipocyte ATAC; high mt fraction (>90%) is a library-quality flag.
- **FRiP** (`<sample>_qc.txt`): ≥ 0.20 is acceptable, ≥ 0.30 is good.
- **Fragment size** (`<sample>_fragsize.txt`): clear nucleosome-free peak (~50–150 bp) and a mono-nucleosome peak (~180–250 bp).
- **PCA** (`deseq2_plots.pdf`): samples should cluster by condition.
- **Hinte concordance** (`concordance_report.txt`): low Jaccard (<0.3) is a flag to revisit MACS2 settings vs Hinte's stringency.

## Known Gaps / Future Work

- TSS enrichment is not computed; would require a mm10 GTF (e.g. GENCODE).
- IDR-based peak consensus is not used; consensus is by `bedtools merge` of per-sample MACS2 calls.
- mm9→mm10 liftover is not in the pipeline; needs to be applied separately when integrating Soccio 2015.

## Reproducibility Metadata

When committing or sharing results, capture in this README (or a sibling `processing_log.md`):

- Date of last full run
- Commit SHA of `main.nf` used
- Versions of all tools (above is the reference; verify in your environment)
- Blacklist version (Boyle Lab mm10 v2 unless overridden)
- Liftover chain file version (if applied)

## Citation

- Original study: Hinte et al. (2023) GSE236575
- DESeq2: Love, Huber, Anders (2014) Genome Biology
- MACS2: Zhang et al. (2008) Genome Biology
- ENCODE blacklist: Amemiya, Kundaje, Boyle (2019) Scientific Reports
- JASPAR 2024: Castro-Mondragon et al. (2024) NAR
- MEME Suite: Bailey et al. (2015) NAR
- HOMER: Heinz et al. (2010) Molecular Cell
- Bowtie2: Langmead and Salzberg (2012) Nature Methods
