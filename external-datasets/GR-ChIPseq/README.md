# Experimental GR Occupancy × HFD Differential Chromatin

## Question

The GSE236575 analysis (`../snATACseq/GSE236575/`) built a *composite-enhancer* model:
AP-1 (led by Junb) opens chromatin on high-fat diet (HFD), licensing glucocorticoid
receptor (GR) binding at sites that were previously inaccessible. That model used
**predicted** GR binding — FIMO scans for the NR3C1 (MA0113.4) motif — and found
AP-1+GR motif co-occurrence enriched in HFD-specific peaks (OR = 1.28, p = 2.3×10⁻⁸).

**This project replaces predicted GR sites with experimentally measured ones.** We
re-analyze published adipocyte GR ChIP-seq / CUT&RUN datasets from raw reads through a
Nextflow pipeline, call GR peaks, and then ask:

> Is experimentally defined GR binding enriched in the HFD-specific differentially
> accessible chromatin (DAC) we found in GSE236575, relative to a background of
> shared (non-differential) peaks?

A positive result would upgrade the composite-enhancer model from *motif potential*
to *measured occupancy*: HFD-opened chromatin is not just GR-motif-bearing, it is
actually bound by GR in adipocytes.

## Relationship to the Bayesian TF model

The broader goal is a Bayesian integration of independent evidence streams to nominate
the transcription factor that is **induced on HFD** and **opens chromatin to enable GR
signaling** (current lead: Junb). Evidence streams already assembled:

1. TRAP-seq induction — Junb HFD↑, P(HFD>CHD) = 0.998, ER = 583 (`../snATACseq/GSE236575/`)
2. ATAC motif enrichment — AP-1 dominant in HFD-specific peaks
3. AP-1 + **predicted** GR composite enrichment — OR = 1.28

This project supplies a stronger version of stream 3: AP-1 + **experimental** GR
co-occupancy. Two-stage plan:

1. **Standalone Bayesian enrichment** — model GR-peak overlap counts in HFD-specific
   vs shared peaks with a beta-binomial / logistic regression under weakly-informative
   priors, yielding a posterior odds ratio + 95% credible interval. This is the Bayesian
   replacement for the Fisher OR = 1.28 from the motif-based scan.
2. **Integrate into the composite TF model** — swap the predicted-GR motif term for the
   measured GR-occupancy term and recompute the integrated Junb nomination posterior.

## Layout — local vs remote

| Location | Runs | Holds |
|----------|------|-------|
| **Remote server** | `main.nf` (Nextflow): FASTQ download → trim → align (mm10) → filter → peak call → bigwig | Large intermediates (FASTQ, BAM), called peak BEDs, bigwigs |
| **This folder (local)** | `*.qmd`: overlap of GR peaks with GSE236575 DAC, enrichment tests, Bayesian integration | Small called-peak BEDs synced back, enrichment tables, figures |

Only the small outputs (peak BEDs, summary tables, optionally bigwigs for locus tracks)
are synced back here for the local qmd analyses. Mirrors the GSE236575 convention:
heavy `main.nf` on the server, `results/` outputs synced, qmd reports local.

## Reference assembly

GSE236575 chromatin coordinates are **mm10 (GRCm38)**. All GR datasets are aligned to
mm10 so peaks overlap natively. Non-mm10 / non-mouse datasets (if used) are lifted to
mm10 with UCSC liftOver before the overlap step.

## Candidate datasets

Dataset selection follows a tissue-match priority (best inference first); all tiers are
in scope:

1. **In vivo mouse eWAT / adipocyte GR ChIP-seq / CUT&RUN** — best match to GSE236575.
2. **3T3-L1 / cultured adipocyte GR ChIP-seq** — includes re-analyzing Yu 2010 from raw.
3. **Human adipocyte GR ChIP-seq** — lifted to mm10 (cross-species caveat noted).

Datasets wired into `main.nf`:

| Study | Source | System | Tier | Genome | Notes |
|-------|--------|--------|------|--------|-------|
| Soccio et al. 2015 | GSE64458 (PRJNA271059) | In vivo mouse eWAT + iWAT GR ChIP, chow | 1 | mm10 | 4 IPs (B6/129 × eWAT/iWAT) + 2 strain-matched iWAT inputs, single-end. eWAT = tissue match to GSE236575; eWAT/iWAT give separate consensus sets. |
| Sobreira et al. (GSE163061) | GSE163061 (PRJNA684576) | Human patient-derived adipocytes, GR ChIP + Dex | 3 | hg38 → mm10 | 16 IPs (8 donors × 2 reps) + 1 shared input, paired-end. Lifted to mm10 after consensus (cross-species; supporting evidence). |

Datasets handled separately (NOT in the pipeline):

| Study | Source | System | Why excluded |
|-------|--------|--------|--------------|
| Yu et al. 2010 | GSE24105 | 3T3-L1, EtOH vs dex | ChIP-**chip** (probe/array-based), no raw FASTQ to re-call. Use the already-lifted mm10 peak BEDs in the old `../snATACseq/ChIPseq/` folder directly as locus tracks. |
| Singh et al. 2016 | no GEO | human adipocyte | no raw data located |

## Pipeline (`main.nf`)

Nextflow DSL2, mirroring the GSE236575 conventions (mm10, bowtie2, samtools,
bedtools in the base environment; sratoolkit/macs2 via environment-modules).
Processes:

1. `DOWNLOAD_GENOME` / `BUILD_BOWTIE2_INDEX` / `GENOME_SIZES` — mm10 reference.
   **Skip these by reusing the GSE236575 index**: set `params.prebuilt_fasta` and
   `params.prebuilt_index_dir` (see below).
2. `DOWNLOAD_BLACKLIST` — ENCODE mm10 blacklist v2.
3. `CHIP_ALIGN` — fasterq-dump from SRA → bowtie2 `--very-sensitive` (auto PE/SE) →
   sorted, indexed BAM.
4. `CHIP_FILTER` — MAPQ ≥ `params.mapq_threshold` (default 30) + blacklist removal.
   PCR-dup removal is delegated to MACS2 (`--keep-dup 1`), keeping the step PE/SE-robust.
5. `MACS2_CALLPEAK` — narrow peaks (GR is point-source), IP vs matched input/IgG.
   Auto-selects `BAMPE`/`BAM`. **GR binding = all GR-occupied peaks** over control,
   regardless of ligand induction (treatment label retained as metadata only).
6. `CONSENSUS_PEAKS` — per-dataset union of IP narrowPeaks, merged (native
   genome coords) → the experimentally-defined GR-bound set.
7. `LIFTOVER_PEAKS` — for non-mm10 datasets (e.g. hg38 human), UCSC liftOver of
   the consensus BED to mm10 (`<dataset>_GR_consensus.mm10.bed`) so it overlaps
   the GSE236575 chromatin natively. liftOver binary + chain auto-downloaded.
8. `CHIP_BIGWIG` *(optional, `params.make_bigwig`)* — CPM-normalized coverage for
   locus tracks (Sgk1, Fkbp5, Angptl4), genome-matched chrom.sizes.

The pipeline is **genome-aware**: every sample declares a `genome` field
(`mm10` or `hg38`); references for each genome present in the sample sheet are
built/obtained independently, reads align to their native genome, peaks are
called natively, and non-mm10 consensus sets are lifted to mm10. Per-genome
metadata (FASTA url, blacklist url, MACS2 `-g` keyword) lives in `params.genomes`.

### Sample sheet

`params.chip_samples` is a list of maps — **currently a template; fill in once
datasets are selected.** One entry per sequencing run (GR IPs *and* their matched
controls):

| Field | Meaning |
|-------|---------|
| `id` | unique sample id (becomes the peak-file basename) |
| `srr` | SRA run accession |
| `dataset` | grouping key for the consensus peak set (e.g. study name) |
| `role` | `'ip'` (GR signal) or `'control'` (input/IgG → MACS2 `-c`) |
| `treatment` | free-text condition label (e.g. `dex`, `veh`); metadata only |
| `control` | id of the matched control run (for `role:'ip'`; `null` for controls) |
| `genome` | reference to align to: `'mm10'` or `'hg38'` (hg38 lifted to mm10 after consensus) |

Multiple IPs may share one control. The IP↔control join is keyed on the `control` id.

### Reusing the existing mm10 index

The GSE236575 run already built `mm10.fa` + the bowtie2 index. To skip the ~1 h
download/build:

```
nextflow run main.nf \
  --prebuilt_fasta     ../snATACseq/GSE236575/results/genome/mm10.fa \
  --prebuilt_index_dir ../snATACseq/GSE236575/results/genome
```

### Cluster modules

Each process loads its own environment-modules (self-contained, like the GSE236575
RNA-seq branch — does **not** depend on what you've `module load`-ed in your shell):

| Process | `module` directive |
|---------|--------------------|
| GENOME_SIZES | `Bioinformatics:samtools/1.21` |
| BUILD_BOWTIE2_INDEX | `Bioinformatics:bowtie2` |
| CHIP_ALIGN | `Bioinformatics:sratoolkit/3.1.1:bowtie2:samtools/1.21` |
| CHIP_FILTER | `Bioinformatics:samtools/1.21:bedtools` |
| MACS2_CALLPEAK | `Bioinformatics:macs2:samtools/1.21` |
| CONSENSUS_PEAKS | `Bioinformatics:bedtools` |
| LIFTOVER_PEAKS | none (UCSC liftOver binary + chain auto-downloaded) |
| CHIP_BIGWIG | `Bioinformatics:samtools/1.21:bedtools` |

`samtools/1.21` and `sratoolkit/3.1.1` are the exact names used by the GSE236575 RNA
branch. **Verify `bowtie2`, `bedtools`, and `macs2`** on the cluster with
`module spider bowtie2 bedtools macs2` and adjust the directives if the names/versions
differ.

### Outputs to sync back

Small files only: `results/peaks/<dataset>/*_peaks.narrowPeak`,
`results/peaks/<dataset>/<dataset>_GR_consensus.bed` (native), and for hg38
datasets the lifted `results/peaks/<dataset>/<dataset>_GR_consensus.mm10.bed`
(this is the one the mm10 overlap analysis uses). Plus optional
`results/bigwig/*.bw` for locus tracks. These feed the local `*.qmd` analysis.

## Planned local analysis (`*.qmd`) — outline

1. Load GR peak BEDs + GSE236575 `HFD_specific`, `CHD_specific`, `shared` peaks
2. Overlap GR peaks with each peak class (bedtools/GenomicRanges)
3. Enrichment test: GR occupancy in HFD-specific vs shared (background)
4. Standalone Bayesian enrichment (beta-binomial / logistic, posterior OR + 95% CrI)
5. Integrate with AP-1 status per peak (reuse `full_motif_scan` AP-1 calls) → measured
   AP-1 + GR co-occupancy; feed into the composite Junb-nomination posterior
6. Locus views at Sgk1, Fkbp5, Angptl4 confirming GR occupancy at HFD-opened peaks

## Remaining TBDs

- **Dataset selection** — user is identifying in vivo eWAT (tier 1) and human (tier 3)
  GR datasets; SRA accessions to be added to the Candidate datasets table.
- **Remote server access** — host, scheduler (SLURM?), and sync-back mechanism for
  peak BEDs / bigwigs to be documented once known.
