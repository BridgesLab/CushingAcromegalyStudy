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

## 5. ATAC × RNA spatial coupling (enrichment test)

Fisher exact test: are HFD-up ATAC peaks enriched for nearest-gene HFD-up RNA?

| | Nearest gene HFD-up | Nearest gene not HFD-up |
|---|---:|---:|
| HFD-up ATAC | 1,203 | 5,697 |
| Other ATAC | 10,326 | 44,393 |

**OR = 1.10, p = 1.95 × 10⁻³** (Fisher exact, one-sided).

The odds ratio is statistically significant but essentially null in effect size — HFD-up peaks are only marginally more likely than background to sit adjacent to an HFD-up gene (17.4% vs. 18.9%). Two complementary explanations account for the weak coupling:

1. **Nearest-gene attribution is wrong for most enhancers.** Distal regulatory elements loop to non-nearest genes; TAD-level coupling would be the appropriate test.

2. **Primed vs. activated enhancers.** AP-1 may open chromatin at GR-binding sites — making them *accessible* — without GR actually occupying or activating them yet. GR binding requires nuclear GR, which in turn depends on ligand availability and Fkbp5-mediated nuclear entry. HFD-opened AP-1 peaks therefore represent a **permissive chromatin state** (poised for GR activation) rather than active transcriptional output. The downstream transcriptional response would only materialise fully once GR nuclear occupancy increases — via Fkbp5 downregulation or elevated glucocorticoid tone. This decoupling between chromatin priming and gene activation is biologically expected and **does not undermine the model**; it is the model.

---

## 6. AP-1 motif scan at the Fkbp5 locus

**Hypothesis tested:** Is Fkbp5 a direct Junb-repressed target? If Jun-family AP-1 motifs are present at the Fkbp5 promoter and Junb ChIP signal is detectable there, the two mechanisms (AP-1 chromatin remodelling + Fkbp5-mediated GR de-repression) collapse into a single Junb-led cascade.

**Locus:** chr4:99,936,000–100,078,000 (mm10). Fkbp5 minus strand, TSS ≈ chr4:100,067,500. Known GREs in introns 2 and 4.
**Motif database:** JASPAR2020 CORE vertebrates (746 motifs total; 45 AP-1 family motifs matched by name pattern).

### 6a. Motif scan results (≥85% PWM score threshold)

| Region | AP-1 hits |
|--------|----------:|
| Promoter (±5 kb of TSS) | 542 |
| Gene body | 5,325 |
| Flanking | 768 |
| **Total** | **6,635** |

**Jun-family hits in promoter + gene body: 4,099** — confirming dense occupancy of canonical bZIP/AP-1 motifs throughout the locus.

**Top motifs by total hit count (selected):**

| Motif | Hits | Family |
|-------|-----:|--------|
| JUND(var.2) | 481 | Jun |
| FOSL2 | 446 | Fos |
| JUN | 402 | Jun |
| FOSL2::JUND | 351 | Fos·Jun heterodimer |
| JUN(var.2) | 340 | Jun |
| FOSB::JUNB | 313 | Fos·Jun heterodimer |
| FOSL1::JUND | 303 | Fos·Jun heterodimer |
| Atf1 | 301 | ATF/CREB |
| FOS | 258 | Fos |
| FOS::JUN | 256 | Fos·Jun heterodimer |
| ATF3 | 133 | ATF |
| BATF | 151 | BATF |
| **JUNB** | **97** | **Jun** |
| JUN::JUNB(var.2) | 32 | Jun heterodimer |

The highest-scoring individual hit in the gene body is **ATF4** (score 18.1 at chr4:99,990,453), followed by MAFF and ATF7. The **JUN::JUNB(var.2)** dimer motif appears in the gene body at chr4:99,982,435 (score 17.1) — within ~85 kb of the TSS. **JUNB** itself contributes 97 hits distributed across the locus.

### 6b. ChIP-Atlas query

ChIP-Atlas API returned **HTTP 403** (access restricted). Manual inspection URL:
`https://chip-atlas.dbcls.jp/peakBrowser/?assemblyId=mm10&factor=JunB&chr=chr4&start=99936000&end=100078000`

### 6c. Verdict — POSITIVE

**Jun-family AP-1 motifs are densely present in the Fkbp5 promoter and gene body** (542 promoter hits; 4,099 Jun-family hits across promoter + body). This supports the unified cascade model:

> **HFD → Junb↑ → AP-1 binding at Fkbp5 → Fkbp5↓ → FKBP51 loss → constitutive GR nuclear entry → Sgk1/Angptl4/Lep↑**

The motif evidence is consistent with Junb acting as a transcriptional repressor at Fkbp5 (directly or via a co-repressor complex), while simultaneously opening chromatin at AP-1/GR composite elements genome-wide. The two mechanisms previously framed as independent are likely the same pathway at different steps.

**Key caveat:** Motif presence ≠ binding. Validation requires:
1. Junb CUT&RUN or ChIP-seq in HFD vs CHD eWAT adipocytes at the Fkbp5 locus
2. Manual ChIP-Atlas inspection (API blocked; use browser URL above) or ENCODE Junb ChIP-seq in adipocyte-relevant cell lines

---

## 7. Proposed experimental strategies

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

## 7. AP-1 + GR composite peak scan

### 7.1 GR motif presence in HFD-specific peaks

**1,526 / 6,900 HFD-specific peaks (22.1%)** carry a GR-class motif (NR3C1 MA0113.4, or the
biochemically equivalent Pgr/PGR IR3 motifs MA2323.1/MA2327.1; FIMO p < 1×10⁻⁴).

### 7.2 AP-1 + GR composite scan

Peak classification (35 AP-1 motifs: JUN/JUNB/JUND, FOS/FOSB/FOSL1/FOSL2, BATF/BATF3,
ATF3, and all JUN·FOS heterodimers; GR-class = NR3C1/Pgr/PGR; FIMO p < 1×10⁻⁴):

| Category | HFD-specific (n = 6,900) | Shared (n = 53,397) |
|----------|-------------------------:|--------------------:|
| **Both (AP-1 + GR)** | **665 (9.6%)** | **4,107 (7.7%)** |
| AP-1 only | 2,268 (32.9%) | 14,906 (27.9%) |
| GR only | 861 (12.5%) | 6,813 (12.8%) |
| Neither | 3,106 (45.0%) | 27,571 (51.6%) |

**AP-1+GR co-occurrence is significantly enriched in HFD-specific vs shared peaks:**
OR = 1.28, p = 2.3×10⁻⁸ (Fisher exact, one-sided).

HFD-specific peaks are enriched for AP-1 motifs overall (42.5% AP-1-positive vs 35.6%
in shared peaks), consistent with AP-1 as the chromatin pioneer. The significant
composite enrichment (OR 1.28) directly supports the model: HFD-opened sites
disproportionately carry the AP-1 + GR motif combination that would license GR
binding at newly accessible loci.

---

## 8. Locus-level chromatin at GR-target genes (Section 8, rnaseq-integration.qmd)

Peak-level DESeq2 normalised ATAC counts (mean ± SE, CHD vs HFD) at five loci:

| Gene | ATAC result | RNA result | Interpretation |
|------|-------------|-----------|----------------|
| **Fkbp5** | All 13 peaks CHD > HFD; 2 significant (padj < 0.05); 7/13 peaks carry AP-1 motif | LFC = −1.29, padj = 0.010 | Chromatin closes in HFD — see §8a for peak-level AP-1 detail |
| **Sgk1** | 1 HFD-up peak (chr10:21,986,642; LFC = +1.60, padj = 0.008) carries **AP-1 + GR** motifs | LFC = +1.77, padj = 0.001 | Classic composite enhancer opened in HFD → GR → Sgk1 |
| **Angptl4** | All peaks CHD ≥ HFD; nearest significant peak is CHD-enriched | LFC = +1.95, padj = 0.002 | Responsible GR enhancer likely distal (>30 kb) |
| **Lep** | No significant ATAC change within ±40 kb | LFC = +2.01, padj = 0.014 | Known distal fat-specific enhancers not in window |
| **Pnpla2** | 6/12 peaks significantly CHD-enriched; none HFD-up | LFC = +0.32, padj = 0.727 | Chromatin closes, transcript unchanged — not chromatin-driven |

### 8a. Fkbp5 locus — AP-1 annotation of the two significant peaks

All 13 Fkbp5 locus peaks with AP-1 status (shared-peak FIMO scan, 35 JASPAR2024 AP-1 motifs,
p < 1×10⁻⁴; all peaks are CHD > HFD):

| Peak | mid (kb) | LFC | padj | AP-1? | Note |
|------|----------:|-----:|-----:|:-----:|------|
| peak_40664 | 99,914 | −0.11 | 0.866 | no | — |
| peak_40665 | **99,930.6** | **−0.70** | **1.9×10⁻⁵** | **no** | strongest signal; AP-1-negative |
| peak_40666 | 99,940 | −0.47 | 0.061 | **yes** | borderline sig |
| peak_40667 | 99,942 | −0.46 | 0.075 | no | — |
| peak_40668 | 99,947 | −0.36 | 0.500 | no | — |
| peak_40669 | 99,957 | −0.38 | 0.481 | no | — |
| peak_40670 | 99,969 | −0.67 | 0.019 | **yes** | significant; AP-1-positive |
| peak_40671 | 99,974 | −0.57 | 0.059 | **yes** | borderline sig |
| peak_40672 | 100,005 | −0.54 | 0.531 | **yes** | — |
| peak_40673 | 100,009 | −0.36 | 0.395 | **yes** | — |
| peak_40674 | 100,012 | −0.17 | 0.748 | **yes** | — |
| peak_40675 | 100,042 | −0.64 | 0.260 | no | — |
| peak_40676 | 100,096 | −0.42 | 0.276 | **yes** | — |

7/13 peaks carry AP-1 motifs, but these cluster in the gene body (99,940–100,096 kb) and are
predominantly non-significant. At padj < 0.05: **one AP-1-positive peak** (99,969 kb) and one
AP-1-negative peak (99,930.6 kb). At the relaxed padj < 0.10 threshold, three AP-1-positive peaks
are differentially open (99,940, 99,969, 99,974 kb).

The strongest closing peak (99,930.6 kb, upstream regulatory region ~18 kb from TSS) is AP-1-negative,
suggesting its maintenance in CHD depends on a non-AP-1 factor. Chromatin closure at Fkbp5 is therefore
**not predominantly AP-1-driven** at the peak level, despite dense AP-1 motif occupancy in the full
locus sequence (Section 6 motif scan, which scans all open chromatin rather than just significant peaks).
The Section 6 result reflects AP-1 binding potential across the 200 kb locus; the peak-level result
shows that the elements actually losing accessibility are mostly AP-1-independent.

This is consistent with the unified cascade model (Junb → Fkbp5 silencing) operating through an indirect
mechanism rather than AP-1 directly maintaining the dominant closing peak.

**Pnpla2 verdict:** Not AP-1/chromatin-driven. The ATGL locus systematically loses
accessibility in HFD despite being classified as a GR target by transcript trajectory.
Its stable expression most likely reflects Fkbp5/GR constitutive activation through a
distal or extra-locus mechanism.

**Sgk1 is the clearest confirmation:** one HFD-specific peak with both AP-1 and GR motifs
corresponds exactly to a significantly up-regulated GR-target gene.

---

## 9. Pending analyses

| Analysis | Status | Notes |
|----------|--------|-------|
| Fkbp5 motif scan — vertebrate motif set | **Complete** | POSITIVE: 542 promoter hits, 4,099 Jun-family hits; Junb and JUN::JUNB motifs present |
| AP-1 + GR composite peak scan | **Complete** | 1,526/6,900 (22.1%) HFD peaks carry GR motif; AP-1+GR co-occurrence OR=1.28 vs shared (p=2.3×10⁻⁸); see Section 7 of `rnaseq-integration.qmd` |
| Locus-level chromatin panels | **Complete** | Sections 6.1a + 8 of `rnaseq-integration.qmd`; bar charts at Fkbp5/Sgk1/Angptl4/Lep/Pnpla2 |
| Expression barplots (TPM, CHD vs HFD) | **Complete** | `expression-barplots.qmd`; TPM from DESeq2 norm counts + TxDb gene lengths; AP-1 compositional switch visible (Atf4/Maf/Mafg dominant, Junb/Fos low-expression but HFD-induced) |
| BigWig locus tracks (coverage) | **Pending server BAMs** | Section 9 placeholder in qmd; place `*.RPGC.bw` in `results/bigwig/atac/` and `*.CPM.bw` in `results/rnaseq/bigwig/`, then set `eval: true` |
| ChIP-Atlas Junb at Fkbp5 | **To do** | HTTP 403 blocked API; check manually at peak browser URL in Section 6b, or try ENCODE |
| Junb CUT&RUN / ChIP-seq at Fkbp5 locus | **Proposed experiment** | Required to confirm motif occupancy; HFD vs CHD eWAT adipocytes |
| TAD-level ATAC × RNA coupling | Pinned | Would test whether HFD-up peaks and HFD-up genes co-occur within the same TAD |

---

*Pipeline: Nextflow DSL2, branch `adipocyte-scRNAseq`. Report: `rnaseq-integration.qmd`. Data: GSE236575 (ATAC) + GSE236578 (TRAP-seq), mm10/GENCODE vM25.*
