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

## Headline result — H1 REJECTED: HFD peaks AVOID GR-rich TADs

The cluster run completed (D2 3T3-L1; `results/tads/D2_{insulation,hicexplorer}_tads.mm10.bed`).
The 3D-rescue hypothesis is **not supported** — the opposite holds. HFD-specific
ATAC peaks are strongly **depleted** in TADs that contain GR-bound elements, vs
shared peaks. Robust across all GR sets, both TAD callers, and width/length
adjustment (full table: `results/enrichment/peak_in_gr_rich_tad.tsv`).

Per-peak posterior OR (HFD-specific in GR-rich TAD vs shared), primary insulation caller:

| GR set | per-peak OR (95% CrI) | width/len-adj OR | TAD-level Poisson IRR |
|--------|----------------------:|-----------------:|----------------------:|
| **eWAT repro** (primary) | **0.31** (0.29–0.33) | 0.27 | 0.88 |
| eWAT union | 0.33 | 0.27 | 0.90 |
| iWAT repro | 0.35 | 0.28 | 0.90 |
| human dex | 0.97 (0.92–1.02) | 0.78 | 0.95 |

P(OR>1) = 0 for every mouse set. TAD-level Poisson: each extra HFD-specific peak
in a TAD *lowers* the expected GR-peak count (IRR < 1, all p ≈ 0) — the genome-wide
3D-rescue claim is negative in one number. (Human dex is the lone near-null per-peak
case, but its width-adjusted OR is also < 1 — same direction, cross-species/in-vitro.)

This mirrors the GR-ChIPseq 2D finding (GR depleted *at* HFD peaks) and extends it
to 3D: HFD remodeling happens in genomic **neighborhoods** that are GR-poor, not
just at GR-poor individual sites. The "OR < 1" branch of the pre-registered decision
rule — HFD remodels chromatin preferentially in non-GR TADs.

## Predicted GR motif replicates the depletion (measured ≈ predicted at TAD scale)

Asked whether the depletion is specific to *measured* GR occupancy or also holds
for GR binding **potential** (motif identity). Counting GR-class motif sites
(NR3C1 `MA0113.4` + Pgr/PGR `MA2323.1`/`MA2327.1`) per TAD and repeating the test:
**the depletion replicates.** Per-peak OR (insulation):

| GR-motif landscape | per-peak OR (95% CrI) | TAD-level IRR |
|--------------------|----------------------:|--------------:|
| all accessible GR-motif sites | 0.55 (0.52–0.58) | 0.95 |
| **shared-only (non-circular)** | **0.40 (0.38–0.43)** | 0.91 |

The shared-only landscape — which *cannot* be inflated by the HFD peaks' own
motifs — shows the strongest depletion; both reproduce in the HiCExplorer caller
(`results/enrichment/peak_in_gr_motif_rich_tad.tsv`). So the measured-vs-predicted
GR discordance (within-peak composite OR 1.28 vs measured depletion) is **purely
local**: at the 3D/TAD scale measured and predicted GR **agree** on depletion.
This closes the occupancy-dynamics escape hatch — the depletion is not merely an
artifact of chow/basal-only ChIP; the unrealized GR motif *potential* is depleted
at HFD-peak TADs too, making the negative H1 result substantially more robust.

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
- `results/tads/D2_{insulation,hicexplorer}_tads.mm10.bed` — TAD coordinates (synced back).
- `tad-analysis.qmd` / `.html` — Stage 1 enrichment (measured GR + predicted GR motif).
- `results/enrichment/peak_in_gr_rich_tad.tsv` — measured-GR per-peak Fisher + Bayesian + adjusted ORs.
- `results/enrichment/tad_gr_enrichment.tsv` — measured-GR TAD-level Poisson IRRs.
- `results/enrichment/peak_in_gr_motif_rich_tad.tsv` — **predicted-GR-motif** per-peak ORs.
- `results/enrichment/tad_gr_motif_enrichment.tsv` — predicted-GR-motif TAD-level IRRs.
- `results/enrichment/tad_gr_enrichment_forest.pdf` — measured-GR forest plot.
- `results/enrichment/tad_gr_motif_vs_chip_forest.pdf` — measured-vs-predicted GR forest.

## Status / next steps

1. **Stage 1 complete (run + render done).** H1 rejected: HFD-specific peaks are
   depleted in GR-rich TADs (eWAT-repro per-peak OR = 0.31; TAD-level IRR = 0.88),
   replicated by predicted GR motif (shared-only OR = 0.40) and by both TAD callers.
2. **Implications for the proposal:** do **not** frame Arm 2 around a genome-wide
   3D-rescue mechanism — the data argue against it. The defensible positive claim
   stays **local** (the 151 motif-validated GR-bound composite HFD peaks). The new,
   reportable genome-wide statement is the *negative*: HFD AP-1 remodeling is
   directed to GR-poor TADs (by both occupancy and motif), reinforcing that GR
   sensitization runs through pre-existing/constitutive GREs (mechanism 1), not a
   GR-rich 3D neighborhood around the AP-1 program.
3. **Stage 2 is now mainly H3, not H2** (H1 negative): test whether the 151
   composite peaks nonetheless cluster in a few metabolic-gene-rich TADs — a local
   3D structure can still exist inside a globally GR-poor-TAD background. ABC
   enhancer-gene predictions for the proposal locus example (Sgk1).
4. Optional robustness: re-run with the **D0** fibroblast TADs (`--stages D0,D2`)
   to confirm the depletion is not an artifact of the D2 domain calls.
