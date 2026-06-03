# GR ChIP-seq integration — what we've learned

*Last updated 2026-06-01. Analysis: `gr-enrichment.qmd` → `results/gr_enrichment/`.*

## The question

GSE236575 built a composite-enhancer model: AP-1 (led by Junb) opens chromatin on
high-fat diet (HFD), licensing glucocorticoid-receptor (GR) binding at newly
accessible sites. That model used **predicted** GR sites (NR3C1 motif scan), giving
AP-1+GR co-occurrence enriched in HFD-specific peaks (Fisher OR = 1.28).

This sub-project replaced predicted GR with **experimentally measured** GR occupancy:
we re-analyzed published adipocyte GR ChIP-seq from raw reads (Nextflow, on the
server) and asked whether measured GR binding is enriched in the HFD-specific
differentially accessible chromatin, vs a background of shared (non-differential) peaks.

## What we ran

| Dataset | System | Condition | Genome | Role |
|---------|--------|-----------|--------|------|
| GSE64458 (Soccio/Lazar) | in-vivo mouse eWAT + iWAT | **chow** | mm10 | tier-1, tissue-matched (eWAT) |
| GSE163061 (Sobreira/Lazar) | human patient adipocytes | **dex** | hg38→mm10 | tier-3, cross-species |

Pipeline: bowtie2 → MAPQ/blacklist filter → MACS2 narrow peaks (IP vs input) →
per-dataset consensus; human consensus lifted to mm10. GR sets tested at two
stringencies: permissive **union** of IP peaks (~110k mouse) and high-confidence
**strain-reproducible** (B6∩129 — the two mouse IPs are different strains).

## Headline result — GR is DEPLETED at HFD-opened chromatin

The opposite of the predicted-motif OR=1.28, and robust across both datasets,
species, conditions, and after adjusting for peak width.

| Contrast (vs shared) | eWAT repro | eWAT union | iWAT repro | human dex |
|----------------------|-----------:|-----------:|-----------:|----------:|
| **HFD-specific** (posterior OR) | **0.09** | 0.12 | 0.15 | 0.69 |
| **CHD-specific** (posterior OR) | 2.16 | 2.28 | 2.66 | 1.88 |

- **Mouse (chow, tissue-matched): strong, width-robust depletion** at HFD-specific —
  P(OR>1)=0, width-adjusted OR 0.09–0.17.
- **Human (dex, cross-species): mild depletion that is NOT significant after width
  adjustment** (OR_adj 0.86, 95% CI 0.70–1.04, p=0.11); the notable human signal is the
  CHD-specific *enrichment* (OR 1.88).
- Across the board GR concentrates on constitutive (**shared**, 60–81% bound in mouse)
  and **CHD-specific** (chow-open, HFD-*closing*) chromatin.
- (Human now uses the canonical pipeline-lifted 5,301-peak mm10 consensus.)

## Interpretation

Measured GR occupancy **qualifies** rather than confirms the composite model:

- **Supports mechanism 1** (Fkbp5/GR brake-release via *pre-existing* GREs): GR-bound
  chromatin that *closes* on HFD (CHD-specific) is exactly the Fkbp5-locus behavior
  documented in the parent project.
- **Argues against a genome-wide mechanism 2** (GR binding the AP-1-opened HFD program):
  the motif *potential* exists but isn't realized as occupancy in either GR ChIP.

**Signal inside the depletion (the real biology):**
- Within HFD peaks, predicted NR3C1 motif predicts measured GR binding
  (OR ≈ 3.0, p = 2.5e-19) → the binding that *is* there is genuine, not noise.
- **151** motif-validated AP-1+GR composite HFD peaks are GR-bound even in chow
  (`results/gr_enrichment/gr_bound_composite_peaks.tsv`) — the Sgk1-like local candidates.
- **Sgk1** itself is GR-bound only in the permissive union, *not* the strain-reproducible
  set → poised in chow, consistent with "awaits activation."

## ⚠️ Leading caveat — agonist-independent vs agonist-bound peaks

**Our GR sets are "all GR-occupied peaks," which conflates two biologically distinct
populations:** agonist-*independent* (basal/constitutive) GR occupancy at already-active
regulatory regions, and agonist-*dependent* (ligand-induced) recruitment. The basal
component dominates the called peaks and sits on constitutive chromatin — plausibly
*driving the apparent depletion at HFD sites*.

The composite model's prediction is specifically about **agonist-dependent** GR
recruitment to AP-1-opened sites. So the correct unit of test may be **agonist-INDUCED
(ligand-gained) GR peaks**, not all GR peaks — and true enrichment at HFD-specific
chromatin could be masked by the basal majority.

Why we can't test this yet with current data:
- GSE64458 mouse: **chow only**, no dex contrast → can't isolate induced peaks.
- GSE163061 human adipocytes: **dex only** (no matched DMSO GR ChIP in the adipocyte
  arm) → can't compute dex-gained differential within this set.

**To settle it we need GR ChIP with paired ±agonist (vehicle vs dex/cort) in adipocytes**,
call the agonist-INDUCED differential peaks, and re-run the enrichment on those. This is
the single most important next dataset to find. (Condition-matched **HFD** in-vivo
adipose GR ChIP would be the ideal but does not appear to exist publicly.)

Secondary caveats: mouse = chow (can't capture HFD-induced binding); human = cross-species
dex *in vitro*, lifted (~20% peak recovery); union sets are over-permissive and shrink ORs
toward 1 (strain-reproducible is the specificity-appropriate readout).

## Implications for the Bayesian TF model

- Feed measured GR as a **qualifying** (not boosting) term; weight it modestly and carry
  the agonist/condition caveat explicitly.
- The defensible positive claim is **local, not genome-wide**: the motif-validated
  GR-bound composite subset (incl. Sgk1) — not the whole 1,078-peak program.

## Outputs

- `gr-enrichment.qmd` / `gr-enrichment.html` — full analysis.
- `results/gr_enrichment/gr_enrichment_results.tsv` — Fisher + Bayesian OR per GR set × class.
- `results/gr_enrichment/gr_enrichment_width_adjusted.tsv` — width-adjusted logistic ORs.
- `results/gr_enrichment/gr_bound_composite_peaks.tsv` — the 151 GR-bound composite peaks + nearest genes.
- `results/gr_enrichment/gr_enrichment_forest.pdf` — forest plot.

## Status / next steps

1. **Sync the one missing file:** `results/peaks/GSE163061_human/GSE163061_human_GR_consensus.mm10.bed`
   (clean 5,301-peak contiguous lift). Until then the qmd uses a local rtracklayer
   fallback (fragmented); re-render once it's present to lock the human numbers.
2. **Find a ±agonist adipocyte GR ChIP dataset** and re-test on agonist-induced peaks
   (the leading caveat above) — could flip the depletion to enrichment.
3. **Stage-2 Bayesian integration:** fold the qualifying measured-GR term into the
   composite Junb-nomination posterior.
