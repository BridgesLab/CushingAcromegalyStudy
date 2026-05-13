# GSE236575 snATAC-seq × TRAP-seq Integration — Results Summary

**Dataset:** Hinte et al. 2024 (PMID 39558077). eWAT adipocytes from AdipER-Cre/NuTRAP mice,
chow diet (CHD) vs high-fat diet (HFD), n=3/group. ATAC-seq (GSE236575) + TRAP-seq (GSE236578).
**Analysis:** Differential ATAC-seq peaks → motif enrichment → matched TRAP-seq DESeq2 → ATAC×RNA integration.

---

## 1. Chromatin remodelling summary (ATAC-seq)

- **3,717 HFD-enriched peaks**, 776 CHD-enriched peaks (FDR < 0.05, |LFC| > 1).
- Motif analysis (AME + HOMER, JASPAR 2024): **AP-1 family** is the dominant enriched motif class in HFD-up peaks; 19/21 tested AP-1 dimer combinations are concordantly enriched.
- GR (NR3C1) motifs are also enriched, consistent with glucocorticoid sensitisation as the functional consequence.
- FoxA/FoxO motifs are constitutively open (present in shared peaks); C/EBPβ demoted from lead position.
- DMRT family motifs were initially flagged but TRAP-seq shows Dmrt1/3/4 are undetected in adipocytes — the ATAC enrichment is an AT-rich sequence artifact (see Section 4).

---

## 2. AP-1 family expression — TRAP-seq (HFD vs CHD)

| Gene | log2FC | padj | P(HFD>CHD) | Evidence ratio | Mean CHD | Mean HFD |
|------|-------:|-----:|-----------:|---------------:|---------:|---------:|
| **Junb** | **1.927** | **0.012** | **0.998** | **582.9** | 36.3 | 137.4 |
| Fos | 1.866 | 0.034 | 0.993 | 136.6 | 80.8 | 294.0 |
| Atf3 | 1.931 | 0.053 | 0.986 | 70.1 | 67.2 | 256.4 |
| Ddit3 | 1.051 | 0.087 | 0.988 | 81.1 | 407.1 | 843.8 |
| Jund | 0.377 | 0.740 | 0.719 | 2.6 | 445.2 | 578.8 |
| Jun | 0.206 | 0.827 | 0.667 | 2.0 | 637.0 | 735.1 |
| Batf3 | −0.098 | 0.953 | 0.451 | 0.8 | 129.7 | 121.1 |
| **Fosl2** | **−0.112** | **0.910** | **0.402** | **0.7** | 945.9 | 875.2 |
| Atf4 | −0.575 | 0.386 | 0.093 | 0.1 | 3406.8 | 2287.6 |
| Fosl1 | not detected | — | — | — | — | — |

**Verdict — AP-1 lead: Junb.**
Junb meets all four pre-specified ranking criteria: highest significant log2FC among well-expressed AP-1 members (padj = 0.012), Bayesian P(HFD > CHD) = 0.998 with an evidence ratio of 583, and 3.8-fold higher mean expression in HFD. Fosl2 — the primary alternative — is flat (LFC = −0.11) and essentially unchanged, ruling it out as the transcriptional driver.

Fos is also significantly upregulated (padj = 0.034) and Atf3 is borderline (padj = 0.053). Both are known Junb heterodimerisation partners; their co-upregulation suggests a Junb/Fos or Junb/Atf3 heterodimer as the active AP-1 complex rather than a Junb homodimer. Ddit3 (CHOP) is borderline significant and highly induced in HFD adipocytes; it is a stress-responsive bZIP factor that can form inhibitory heterodimers with C/EBP proteins and warrants attention as a secondary signal.

---

## 3. Fkbp5 downregulation — an independent GR-sensitisation mechanism

| Gene | log2FC | padj | P(HFD>CHD) | Mean CHD | Mean HFD |
|------|-------:|-----:|-----------:|---------:|---------:|
| **Fkbp5** | **−1.292** | **0.010** | **0.001** | 1414.6 | 578.1 |
| Sgk1 | 1.770 | 0.001 | 1.000 | 323.4 | 1103.2 |
| Angptl4 | 1.949 | 0.002 | 1.000 | 1978.5 | 7638.5 |
| Lep | 2.009 | 0.014 | 0.997 | 14331.1 | 57685.3 |

**Fkbp5 encodes FKBP51**, the co-chaperone that binds glucocorticoid receptor (GR) in the Hsp90 complex and suppresses nuclear translocation. It is also a canonical GR target gene, normally providing negative feedback: GR activation → Fkbp5 induction → GR inhibition.

HFD adipocytes show **significant Fkbp5 downregulation** (padj = 0.010, LFC = −1.29, ~2.4-fold decrease in normalised counts). This is paradoxical relative to the canonical feedback model but coherent as a sensitisation mechanism: if HFD suppresses the negative feedback brake via epigenetic silencing or upstream repressors, GR becomes constitutively more responsive to circulating glucocorticoids *without requiring additional ligand*. The simultaneously upregulated canonical GR targets Sgk1, Angptl4, and Lep confirm that GR output *is* elevated in HFD adipocytes.

Importantly, **Fkbp5 downregulation provides a distinct, parallel explanation for GR sensitisation** that does not require AP-1-driven chromatin remodelling — or the two mechanisms may act synergistically: AP-1 opens chromatin at GR binding sites while Fkbp5 suppression increases GR nuclear availability. Temporal resolution would require time-course data, but the combination is internally consistent.

---

## 4. Mechanisms ruled out

| Mechanism | Key evidence | Verdict |
|-----------|-------------|---------|
| Fosl2 as AP-1 driver | LFC = −0.11, padj = 0.910, ER = 0.67 | Ruled out |
| DMRT family (ATAC motif) | Dmrt1/3/4 undetected; Dmrt2 detected but HFD-*down* | AT-rich artifact confirmed for DMRT1/3/4; Dmrt2 not a sensitisation driver |
| Coactivator drive (NCOA1/2/3, MED1) | All HFD-down or flat, none significant | Ruled out |
| Ligand amplification via Hsd11b1 | LFC = −0.93, padj = 0.110, P(HFD>CHD) = 0.016 | Ruled out (HFD-down, not up) |
| VDR pathway | Vdr flat (padj = 0.956); all pathway members unchanged | Ruled out as sensitisation driver |

---

## 5. Proposed experimental strategies

### Strategy A — Junb overexpression (AP-1/chromatin model)
**Rationale:** Junb is the highest-confidence HFD-upregulated AP-1 factor in adipocytes. If Junb drives the observed chromatin remodelling, forced Junb expression in CHD adipocytes should recapitulate the HFD ATAC signature and potentiate GR target gene induction.

**Approach:**
1. Adenoviral or AAV-mediated Junb overexpression in primary CHD eWAT adipocytes or differentiated 3T3-L1 cells.
2. ATAC-seq: test whether HFD-like peaks open at AP-1/GR composite motifs.
3. GR target panel (Sgk1, Angptl4, Lep, Fkbp5) ± dexamethasone: test for potentiated GR response.
4. Co-expression of Fos (also HFD-up) to reconstitute the likely Junb/Fos heterodimer.

**Expected outcome:** Junb OE increases chromatin accessibility at AP-1 motif-containing loci and sensitises GR targets. Failure would argue that Junb is a consequence of HFD, not a driver (i.e., the ATAC changes are upstream).

### Strategy B — Fkbp5 knockdown (GR brake-release model)
**Rationale:** Fkbp5 is significantly downregulated in HFD adipocytes (padj = 0.010). As the primary negative regulator of GR nuclear entry, its loss would constitutively increase GR activity independent of chromatin state.

**Approach:**
1. siRNA or shRNA knockdown of Fkbp5 in CHD primary adipocytes.
2. GR nuclear localisation by immunofluorescence or cellular fractionation ± basal/low-dose corticosterone.
3. GR target panel: does Fkbp5 KD in CHD cells recapitulate the HFD-elevated Sgk1/Angptl4/Lep signature?
4. Metabolic readout: Pnpla2 (ATGL) activity, lipolysis rate as a functional GR-sensitisation endpoint.

**Expected outcome:** Fkbp5 KD increases baseline GR nuclear occupancy and GR target expression in CHD adipocytes, partially phenocopying HFD. This would establish Fkbp5 downregulation as sufficient (not merely correlative) for GR sensitisation.

### Distinguishing the two mechanisms
The strategies are not mutually exclusive. A combined experiment — Junb OE + Fkbp5 KD vs each alone — would test whether they are additive/synergistic. If Fkbp5 KD alone fully recapitulates the GR-sensitised transcriptome without ATAC remodelling, the chromatin model is secondary. If Junb OE recapitulates ATAC changes but not GR target induction without Fkbp5 reduction, the brake-release step is required downstream.

---

## 6. Outstanding analysis (pending enrichment fix)

The ATAC × RNA enrichment test (Fisher exact: are HFD-up ATAC peaks enriched near HFD-up RNA genes?) was confounded by a gene-column loading bug in the qmd script (now fixed). The corrected result — which will quantify whether the chromatin remodelling is spatially coupled to the transcriptional response — should be available on the next render.

---

*Pipeline: Nextflow DSL2, branch `adipocyte-scRNAseq`. Report: `rnaseq-integration.qmd`. Data: GSE236575 (ATAC) + GSE236578 (TRAP-seq), mm10/GENCODE vM25.*
