# 3D chromatin / TAD integration — what we're testing

*Last updated 2026-06-03. Pipeline: `main.nf` (cluster) → `results/tads/`.
Analysis: `tad-analysis.qmd` → `results/enrichment/`.*

## The question

GSE236575 built a composite-enhancer model: AP-1 (Junb) opens HFD-specific
chromatin, with predicted AP-1+GR composite motifs enriched there (Fisher OR =
1.28). The GR-ChIPseq sub-project then showed that **measured** GR occupancy is
*depleted* at those HFD-specific peaks (eWAT strain-reproducible posterior OR =
0.09) — GR concentrates on constitutive (shared) and HFD-*closing* (CHD-specific)
chromatin instead.

Both can be true if the mechanism is **3D**: AP-1-opened enhancers act on
GR-mediated transcription by **looping to a GR-bound promoter elsewhere in the
same TAD**, rather than by direct co-binding. This sub-project tests that.

- **H1 (Stage 1, this build):** HFD-specific ATAC peaks are enriched in TADs that
  contain GR-bound elements, vs shared (non-differential) peaks.
- **H2 (Stage 2):** ABC-predicted targets of HFD-specific AP-1 enhancers are
  enriched for HFD-up TRAP-seq DEGs (Sgk1, Angptl4, Lep, Pnpla2, Tsc22d3, Fkbp5).
- **H3 (Stage 2):** the 151 motif-validated GR-bound composite HFD peaks cluster
  in a few metabolic-gene-rich TADs (3D structure, not scattered).

## What we built (Stage 1)

A cluster Nextflow pipeline that re-processes 3T3-L1 adipogenesis Hi-C
(**GSE95533**, Siersbaek 2017) from the deposited HiCUP read-pair lists into
balanced cooler matrices and calls TADs with **two independent callers**
(cooltools insulation primary, HiCExplorer hicFindTADs sensitivity), lifted
mm9→mm10. A local Quarto report then runs the enrichment:

- **Per-peak Fisher + Bayesian OR** (HFD-specific vs shared × GR-rich-TAD), with a
  width/TAD-length-adjusted logistic robustness check.
- **TAD-level Poisson** (per-TAD GR-peak count ~ HFD-specific-peak count, TAD
  length offset) — the genome-wide 3D-rescue effect in one IRR.

GR sets are identical to GR-ChIPseq (eWAT/iWAT union + strain-reproducible, human
dex), so Stage 1 is directly comparable. Primary readout = eWAT strain-reproducible.

## Headline result

**Pending the Great Lakes run.** The pipeline and analysis are complete; the
headline OR populates `tad-analysis.qmd` and the table below once the mm10 TAD
BEDs are synced into `results/tads/`. Decision rule (per-peak, eWAT repro):

| Outcome | Reading |
|---------|---------|
| OR > 1.5, P(OR>1) > 0.95 | **H1 supported** → 3D-rescue; proceed to Stage 2, reframe Arm 2 |
| OR ≈ 1 (CrI spans 1) | **H1 not supported** → local 151-peak claim stands; Stage 2 for H3 |
| OR < 1 | GR-rich TADs *depleted* of HFD peaks → HFD remodels non-GR TADs (also interesting) |

## ⚠️ Leading caveat — D2, not mature adipocyte

GSE95533 standard Hi-C exists **only at D0 / 4h / D2** — there is **no D6/D7
mature-adipocyte Hi-C** in this series (later timepoints have only ChIP/RNA/PCHi-C).
**D2 (early differentiation) is the most adipocyte-committed Hi-C available.** This
is acceptable for the coarse TAD-level question because TAD boundaries are largely
invariant across adipogenesis (Siersbaek 2017's own finding: promoter loops rewire
while domain structure is broadly stable), but it limits fine-grained per-loop
claims. 3T3-L1 is also a cell line, not primary eWAT.

Secondary caveats: TAD calling is method-dependent (two callers run; decision must
reproduce in both); mm9→mm10 liftover recovery reported by the pipeline; the
GR-set caveats carry over from GR-ChIPseq (mouse = chow, human = cross-species dex,
union sets over-permissive).

## Deviations from the original brief

- **No mature-adipocyte Hi-C** (brief assumed GSE95533 D6). Using D2 + TAD-invariance
  argument; documented above and in `data/README.md`.
- **No pre-called TADs were downloadable** anywhere (GEO raw-only; ENCODE has zero
  3T3-L1 Hi-C and one mouse Hi-C [adrenal]; 4DN needs auth; 3D Genome Browser serves
  only via its SPA). Hence the from-raw pipeline (Dave's call to process GSE95533).
- **cooltools/hicexplorer via conda**, not cluster modules (portability; they are
  not standard Great Lakes modules).

## Outputs

- `main.nf` / `nextflow.config` / `nextflow.slurm` — cluster Hi-C → mm10 TAD pipeline.
- `results/tads/<stage>_<caller>_tads.mm10.bed` — TAD coordinates (synced back).
- `tad-analysis.qmd` / `.html` — Stage 1 enrichment.
- `results/enrichment/peak_in_gr_rich_tad.tsv` — per-peak Fisher + Bayesian + adjusted ORs.
- `results/enrichment/tad_gr_enrichment.tsv` — TAD-level Poisson IRRs.
- `results/enrichment/tad_gr_enrichment_forest.pdf` — forest plot.

## Status / next steps

1. **Run `sbatch nextflow.slurm` on Great Lakes**, sync `results/tads/*.mm10.bed`
   back, render `tad-analysis.qmd` → lock the Stage 1 headline OR.
2. Confirm the decision reproduces in the HiCExplorer sensitivity caller (and,
   optionally, the D0 contrast).
3. If H1 positive → **Stage 2** (ABC enhancer-gene predictions; H2/H3) and the
   two proposal figures (Stage 3).
