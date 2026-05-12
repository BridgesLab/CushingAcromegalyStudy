# Decision Memo — GSE236575 RNA-seq Integration (Task 1)

**Date:** _(fill after pipeline run)_  
**Pipeline run:** `nextflow run main.nf -resume`  
**Targeted gene table:** `results/rnaseq/deseq2/rnaseq_targeted_genes.tsv`

This memo records the three decision-gate verdicts from the RNA-seq integration.
Populate the *Observed values* column after the pipeline completes and
`rnaseq-integration.qmd` is rendered.

---

## Decision 1 — AP-1 lead candidate for in vitro overexpression

**Question:** Between Junb and Fosl2, which shows stronger HFD upregulation in
eWAT adipocytes, ranking it as the lead AP-1 candidate for planned
overexpression studies?

**Criteria (in order of priority):**
1. Higher log2FC (HFD/CHD) in TRAP-seq
2. Stronger Bayesian posterior P(HFD > CHD) under Normal(0,1) prior
3. Higher mean normalised counts in HFD (expression level context)
4. Concordance with ATAC — does the lead gene also have more HFD-up ATAC
   peaks in its ±50 kb window?

| Gene | log2FC | padj | P(HFD>CHD) | ER | mean_CHD | mean_HFD |
|------|--------|------|------------|-----|----------|----------|
| Junb | _TBD_  | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| Fosl2 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |

**Verdict:** _TBD after pipeline run_

**Supporting AP-1 context:** ATAC motif analysis identified 19/21 AP-1 dimers
as concordant HFD-enriched at the chromatin level. The RNA-seq comparison
determines which specific heterodimer partner is the transcriptional driver
most suitable for perturbation.

---

## Decision 2 — DMRT family expression: AT-rich artifact or real signal?

**Question:** Are DMRT1, DMRT2, DMRT3, DMRT4 expressed in eWAT adipocytes?
If undetected (mean normalised count < 5), the ATAC motif enrichment is
an AT-rich sequence artifact and DMRT family can be ruled out as a
sensitization mechanism.

| Gene | mean_CHD | mean_HFD | detected | log2FC | padj |
|------|----------|----------|----------|--------|------|
| Dmrt1 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| Dmrt2 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| Dmrt3 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| Dmrt4 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |

**Verdict:** _TBD after pipeline run_

**Expected outcome:** All four undetected → confirm as artifact.
If any DMRT gene is detected and HFD-regulated, escalate for manual review
before attributing the ATAC motif enrichment to it.

---

## Decision 3 — Coactivator and ligand-amplification mechanism status

**Question:** Do NCOA1/2/3 (coactivator drive), MED1 (mediator coactivator),
and HSD11B1 (ligand amplification via cortisone→cortisol conversion) show
HFD-upregulated expression that could explain GR sensitization independent
of chromatin opening?

### Coactivator drive (NCOA1/2/3, MED1)

| Gene | log2FC | padj | P(HFD>CHD) | mean_CHD | mean_HFD | Verdict |
|------|--------|------|------------|----------|----------|---------|
| Ncoa1 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| Ncoa2 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| Ncoa3 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| Med1  | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |

**Coactivator verdict:** _TBD_

Interpretation guide:
- Any NCOA paralog significantly HFD-up (padj < 0.05, LFC > 0.585) → 
  coactivator-drive mechanism is plausible; propose as a competing hypothesis
  alongside chromatin remodeling.
- All flat/downregulated → coactivator-drive does NOT explain sensitization;
  chromatin model remains primary.

### Ligand amplification (HSD11B1, HSD11B2)

| Gene | log2FC | padj | P(HFD>CHD) | mean_CHD | mean_HFD | Verdict |
|------|--------|------|------------|----------|----------|---------|
| Hsd11b1 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |
| Hsd11b2 | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |

**Ligand amplification verdict:** _TBD_

Interpretation guide:
- HSD11B1 HFD-up → elevated local cortisol regeneration in adipocytes;
  supports ligand-amplification as a parallel or upstream mechanism.
- HSD11B2 HFD-up → increased cortisol inactivation (paradoxical); rule out.
- HSD11B1 is also a GR target gene — HFD upregulation could be either cause
  (ligand amplification driving sensitization) or consequence (sensitized GR
  driving HSD11B1). Temporal resolution requires separate study.

---

## Summary and recommendation for Task 2 (GR ChIP-seq)

_(Fill after pipeline run)_

| Decision | Verdict | Implication for Task 2 |
|----------|---------|------------------------|
| AP-1 lead | _TBD_ | Lead AP-1 TF for composite-motif × ChIP stratification |
| DMRT artifact | _TBD_ | If confirmed artifact, remove from motif analysis report |
| NCOA1 upregulated | _TBD_ | If yes, note as competing mechanism in proposal |
| HSD11B1 upregulated | _TBD_ | If yes, ChIP-seq Hsd11b1 locus track is a priority panel |

**Recommendation on Task 2 (GR ChIP-seq integration):**
- **Proceed** if RNA-seq confirms AP-1 or VDR upregulation (validates motif findings as TF-activity-driven, not passive chromatin).
- **Defer** if RNA-seq shows flat AP-1 expression (motif enrichment may reflect constitutive open chromatin rather than active TF drive; ChIP-seq would be needed to distinguish, but the prior probability drops).
