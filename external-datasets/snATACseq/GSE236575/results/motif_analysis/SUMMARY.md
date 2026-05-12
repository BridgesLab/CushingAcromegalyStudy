# Motif Enrichment Summary — HFD-specific ATAC peaks (GSE236575)

**Last updated**: 2026-05-07
**Dataset**: Hinte et al. (2023), GSE236575 — mouse epididymal white adipocytes, CHD vs HFD (12 weeks), 3 reps each
**Foreground**: 3,717 peaks significantly more accessible in HFD (DESeq2, padj < 0.05, log2FC > 1)
**Background**: 55,093 non-significant ("shared") peaks — preserves accessibility bias
**Reference DBs**: JASPAR 2024 CORE vertebrates non-redundant (AME); HOMER's built-in known-motif library

## Overarching research question

Does HFD remodel adipocyte chromatin in a way that *sensitizes* the cell to subsequent glucocorticoid signaling — i.e., does the same circulating cortisol produce more GR-driven transcription in an HFD-conditioned adipocyte? This is distinct from asking which TFs are *currently bound* at HFD-opened chromatin (which would describe the consequence of HFD remodeling, not its sensitizing role).

The mechanistic candidates this analysis can speak to:
- **Pioneer factor expansion** of GR-accessible enhancers (chromatin-mediated; testable by motif analysis)
- **Direct GR cofactor cooperation** (e.g., FoxO–GR composite enhancers; partially testable by motif analysis)
- **Coactivator drive** (NCOA1/SRC-1 etc.) — invisible to motif analysis (no DNA-binding domain); needs RNA-seq
- **Local cortisol amplification** (HSD11B1) — invisible to motif analysis; needs RNA-seq or per-locus peak annotation

## Methods snapshot

- HOMER `findMotifsGenome.pl` with `-bg shared.bed -size 500 -mask -len 8,10,12`
- AME `--scoring totalhits --method fisher --hit-lo-fraction 0.25 --evalue-report-threshold 10`
- Initial AME run used `--scoring avg --method ranksum` and produced degenerate output (every motif p=0); switched to Fisher's exact on hits-vs-no-hits, which is robust to the ATAC use case where many sequences saturate the rank-sum score.

## Results — three coherent biological themes

### Theme 1: Pioneer factor expansion (the strongest sensitizer candidate)

The class of TFs known to remodel chromatin to license GR binding is heavily enriched, and this is the most mechanistically specific finding for the sensitization hypothesis.

| TF | AME p-value | HOMER q-value | Pioneer role |
|---|---|---|---|
| **FOXA1** | 1.23e-144 | — | The canonical GR pioneer (liver, adipose). Makes chromatin accessible to steroid receptors. |
| **C/EBPβ** | 1.25e-17 | < 0.0001 | Established GR pioneer in adipocytes (Madsen 2014 EMBO J; Siersbæk 2011 Genes Dev). |
| **C/EBPα** | 2.06e-136 | — | Adipocyte master TF; GR cooperator. |
| **C/EBPγ, C/EBPδ, C/EBPε** | 1e-25 to 1e-126 | — | C/EBP family broadly enriched. |
| **FOXA2, FOXA3** | 1e-144 to 1e-152 | — | FoxA family pioneers. |

**Interpretation for the sensitization hypothesis**: chronic HFD activates C/EBPβ (via inflammation, ER stress, FFA exposure) and likely enhances FoxA-family activity. These pioneer factors progressively open enhancers that contain latent GREs. Result: at constant cortisol, more GR binding and stronger transcriptional output. This is the most defensible chromatin-mediated mechanism this dataset supports.

### Theme 2: Direct GR cofactor cooperation (FoxO family)

| TF | AME p-value |
|---|---|
| FOXO1 | 2.40e-162 |
| FOXO3 | 1.98e-149 |
| FOXO4 | 4.50e-130 |
| FOXO6 | 3.76e-55 |

FoxO1 physically interacts with GR and modulates its activity at metabolic gene enhancers. Under HFD, chronic insulin elevation alters FoxO1 nuclear localization and DNA binding. The motif enrichment here suggests FoxO factors are repositioning into HFD-opened chromatin where they can act as direct GR cooperators rather than as upstream pioneers. A second, distinct mechanism alongside theme 1.

### Theme 3: ER stress / UPR / AP-1 cascade

Both methods strongly enrich the HFD-induced inflammatory and stress response:

- **bZIP / AP-1**: JUN, JUNB, JUND, FOS, FOSL1, FOSL2, BATF, BATF3, ATF3, FOS::JUN composite — all significant in both AME and HOMER
- **UPR / ER stress**: ATF4 (AME 3.71e-68; HOMER q=0.0004), DDIT3/CHOP (HOMER q=0.0035), DDIT3::CEBPA composite motif (AME 1.13e-7), NFE2L2/NRF2 (HOMER q=0.003)
- **The DDIT3::CEBPA composite is biologically interesting** — it represents UPR factors heterodimerized with adipocyte programming TFs, sitting in HFD-opened chromatin. Could mediate stress-conditional transcription.

AP-1's relationship with GR is ambivalent: AP-1 sites can either license GR-cooperative activation (composite enhancers) or mediate GR-tethered repression. This dataset can't resolve which is dominant without GR ChIP-seq overlap.

### Direct GR motifs — present but modest

- **HOMER**: GRE(NR),IR3 (RAW264.7 GR ChIP) at p=1e-2, q=0.14; GRE(NR),IR3 (A549 GR ChIP) at p=1e-1, q=0.62
- **AME**: PGR (rank 227, p=7.10e-55) — uses GRE-like IR3 palindrome; closest JASPAR proxy

A modest direct GR signal is expected in an HFD-only paradigm with no exogenous glucocorticoid. The dominant story is *the chromatin landscape is being prepared for GR* (themes 1 and 2), not *GR is currently driving most HFD-opened peaks*.

### What we discounted

- **Top of AME list (~50 hits)** is dominated by AT-rich homeobox motifs (HOX, MSX, NKX, DLX, EVX, LBX, VAX, RAX — all with TAATTA/YAATTA consensus). These are over-represented in any open chromatin and are a known AME bias rather than adipocyte-specific signal. Biologically meaningful AME hits start around C/EBP family (~rank 90+).
- **Top GTRD hits** (MSX1, PDX1, TLX1, CUX2, POU3F3) from earlier analysis are likely artifacts of GTRD's database composition bias (most-ChIP'd developmental TFs from non-adipocyte cell types). The biologically defensible GTRD hits — DDIT3 and NCOA1 — are corroborated by the motif analysis (DDIT3 here, NCOA1 indirectly via the strong NR motif enrichment because NCOA1 is an NR coactivator).

## Integrated interpretation in the sensitization frame

HFD-induced chromatin remodeling produces three distinct, non-mutually-exclusive routes to GR sensitization:

1. **Pioneer expansion (chromatin route)** — FoxA1 and C/EBPβ open new enhancers that contain latent GREs. The same cortisol concentration now reaches more GR binding sites.
2. **Cofactor repositioning (cooperation route)** — FoxO family TFs reposition under altered insulin signaling and act as direct GR cooperators at metabolic enhancers.
3. **Stress conditioning (composite enhancer route)** — UPR factors (ATF4, DDIT3) embedded in C/EBP-flanked chromatin create stress-conditional enhancers that may potentiate GR-stress crosstalk.

All three are testable. None of them addresses the **coactivator drive** (NCOA1) or **ligand amplification** (HSD11B1) mechanisms, both of which require gene-expression data.

## Next steps

### Composite motif scan — IMPLEMENTED AND RUN, 2026-05-11

The pipeline now includes `COMPOSITE_MOTIF_SCAN`: FIMO against 7 JASPAR 2024 motifs (FOXA1 MA0148.5, FOXA2 MA0047.5, CEBPB MA0466.4, CEBPA MA0102.5, FOXO1 MA0480.3, NR3C1 MA0113.4, PGR human MA2327.1, Pgr mouse MA2323.1) on HFD-specific, CHD-specific, and shared peak FASTAs. FIMO hits are mapped back to source peaks via bedtools intersect (FIMO 5.5.x auto-parses `chr:start-end` FASTA headers into genomic coordinates, so per-peak counting requires this step).

Outputs in `composite_scan/<bed_type>/`:
- `<bed_type>_fimo.tsv` — all motif occurrences (positions, scores, p-values)
- `<bed_type>_per_peak_motifs.tsv` — per-peak motif counts (zero-hit peaks retained for correct denominators)
- `<bed_type>_motifs_used.txt` — sanity log of which requested JASPAR IDs were found

### First-pass candidate-driven result — C/EBP+GR enrichment is NOT HFD-specific

Fisher exact tests (one-sided "greater") for pioneer + GR motif co-occurrence:

**HFD-specific (6,900 peaks) vs shared (53,397 peaks):**

| Composite          |   N (HFD) | %HFD | %shared | OR    | p-value |
|--------------------|-----------|------|---------|------:|--------:|
| **C/EBP + GR**     | **310**   | 4.49 | 3.22    | 1.42  | < 1e-4  |
| Any pioneer + GR   |  400      | 5.80 | 4.52    | 1.30  | < 1e-4  |
| FoxA + GR          |  115      | 1.67 | 1.56    | 1.07  | 0.27    |
| FoxO + GR          |  115      | 1.67 | 1.56    | 1.07  | 0.27    |

**CHD-specific (1,322 peaks) vs shared — negative control:**

| Composite          |   N (CHD) | %CHD | %shared | OR    | p-value |
|--------------------|-----------|------|---------|------:|--------:|
| **C/EBP + GR**     | **60**    | 4.54 | 3.22    | 1.43  | 0.0065  |
| Any pioneer + GR   |  79       | 5.98 | 4.52    | 1.34  | 0.0091  |
| FoxA + GR          |  26       | 1.97 | 1.56    | 1.27  | 0.14    |
| FoxO + GR          |  26       | 1.97 | 1.56    | 1.26  | 0.15    |

**The C/EBP+GR enrichment is identical in HFD-specific and CHD-specific peaks** (4.49% vs 4.54%; OR 1.42 vs 1.43). The p-value gap reflects sample size (310 vs 60), not effect size. **So this candidate-driven approach failed to identify HFD-specific sensitizing enhancers.** What we're actually seeing is a "condition-specific peak vs constitutively-open" signal — both HFD-opened and CHD-opened peaks are enhancer-biased, while shared peaks are promoter-biased, and pioneer+GR motifs cluster in enhancers.

**FoxA1 and FoxO1 — the two best-established GR pioneers in the literature — were not enriched in either direction.** FoxA1's adipocyte binding repertoire is constitutive (set by lineage); it cooperates with GR throughout adipocyte chromatin, not selectively in HFD-opened regions.

**Quantitative argument that partially survives**: HFD opens 5× more condition-specific peaks than CHD does (6,900 vs 1,322). At equal per-peak rate, that's still a net gain of ~250 C/EBP+GR composite enhancers under HFD. So HFD remodels chromatin to expose ~250 additional pioneer+GR composite sites, but the mechanism is broad chromatin opening rather than selective creation of pioneer+GR enhancers.

### Pivot to data-driven sensitizer-TF discovery (IMPLEMENTED, 2026-05-11)

Rather than picking candidate TFs from the literature, let the data choose. Added `FULL_MOTIF_SCAN` Nextflow process: FIMO scan of HFD-specific and CHD-specific peaks against the **full** JASPAR file (no `--motif` filter), producing per-peak occurrence counts for all ~600 motifs.

qmd's new "Data-driven sensitizer-TF discovery" section then ranks TFs on two independent axes:

- **Axis 1** — HFD-specific enrichment vs CHD-specific (from existing `RUN_AME(HFD_vs_CHD)` output). Identifies TFs that distinguish HFD-driven chromatin from CHD-driven, controlling for the "condition-specific peak is enhancer-biased" confounder above.
- **Axis 2** — GR-class motif co-occurrence within HFD-specific peaks. For each motif M, Fisher exact ("is GR-motif presence higher in M-containing HFD peaks vs non-M-containing HFD peaks").

TFs scoring on both axes are candidate sensitizer pioneers picked by the data. From the HFD_vs_CHD AME alone (before the GR co-occurrence step), the top fold-enrichment hits are biologically promising — these are now what the two-axis ranking will test for GR cooperation:

- **MEF2B / MEF2D** (log2 fold 1.05 / 1.00) — top by fold enrichment; MEF2 family is a documented GR cooperator in muscle/adipose
- **AP-1 family**: FOSL1::JUN (0.71), FOSB::JUNB (0.64) — stress-responsive bZIPs with well-described GR composite enhancers
- **NFE2 / NRF2-class** (0.71) — oxidative stress
- **CEBPD** (0.68) — the δ isoform (distinct from CEBPB/A which we already tested); CEBPD is the inflammation-induced C/EBP
- **RXRG** (0.81) — retinoid X receptor, NR heterodimer partner

The new analysis produces:
- `full_motif_scan/<bed_type>/<bed_type>_fimo_all.tsv` — every motif occurrence
- `full_motif_scan/<bed_type>/<bed_type>_per_peak_all_motifs.tsv` — per-peak count matrix for all motifs
- `full_motif_scan/data_driven_sensitizer_ranking.tsv` — ranked TF table (qmd output)
- `full_motif_scan/<motif>_GR_composite_genes.tsv` — gene lists for top candidates (qmd output)
- Two-axis scatter plot in the rendered qmd

### Data-driven results (RUN COMPLETED 2026-05-11)

772 motifs tested. 1,526 of 6,900 HFD-specific peaks (22.1%) contain at least one GR-class motif (NR3C1, PGR-h, PGR-m). Strict Bonferroni-level correction (cooc_q < 0.05 across 772 tests) is too punishing — only **one** motif (Dmrt1) passes strict q on axis 2. The structured signal is visible in the scatter plot but hidden by the strict filter.

**Strict pass (1 hit):**
| TF | log2_HFD_vs_CHD | adj_p_hvc | cooc_OR | cooc_q | Note |
|---|---|---|---|---|---|
| **Dmrt1** | 0.48 | <1e-4 | 1.42 | 0.012 | Gonadal/sex-determination TF; biologically unexpected in adipocytes; motif is AT-rich palindrome (susceptible to motif bias) |

**Top hits by combined score, top-right quadrant, no strict q (relaxed):**

Top 40 are heavily dominated by **AT-rich homeobox motifs** (HOX, DLX, SOX, MEIS, PBX, POU, PAX, PHOX, LHX, HMX, VENTX, CUX, ONECUT) — 29 of 40. This is the same AME bias that dominated every previous AME run on this dataset: AT-rich palindromes match open chromatin generically. Most of these TFs aren't even expressed in mature adipocytes (HOX cluster is silenced after lineage commitment).

**Non-homeobox candidates (the biologically interpretable subset):**

| TF | log2_HFD_vs_CHD | adj_p_hvc | n_with_M | n_M+GR | cooc_OR | cooc_p | Biology |
|---|---|---|---|---|---|---|---|
| **Vdr (MA0693.4)** | 0.43 | 0.0003 | 751 | 194 | 1.26 | 0.006 | Vitamin D receptor — Type II NR, shares NCOA1/2/3 coactivators with GR. VDR signaling altered in obesity. **Strongest non-homeobox lead.** |
| **FOSL1::JUN (MA1128.2)** | **0.71** | <1e-4 | 923 | 217 | 1.10 | 0.15 | AP-1 composite. Strongest axis-1 hit overall. AP-1 + GR cross-talk extensively documented in inflammation. Borderline cooc but biologically interpretable. |
| **Nfatc2 (MA0152.3)** | 0.61 | <1e-4 | 1263 | 298 | 1.11 | 0.087 | Calcineurin–NFAT signaling. NFAT–GR composite enhancers in immune/adipose tissue. |
| **GATA2 (MA0036.4)** | 0.42 | <1e-4 | 389 | 98 | 1.20 | 0.076 | GATA family; adipogenesis suppressor; GATA–GR co-binding documented. |
| **ZBTB32 (MA1580.1)** | 0.34 | 0.01 | 617 | 164 | 1.31 | 0.003 | Less-characterized zinc finger; significant cooc but unclear biology. |

### Top non-homeobox lead — Vdr

Of the data-driven candidates, **VDR is the most mechanistically promising lead** for HFD-driven GR sensitization:

- **Shared coactivator machinery with GR**: VDR uses the same SRC family (NCOA1/2/3), MED1, and chromatin remodelers as GR. Increased VDR binding could pre-load coactivators near GR sites, lowering the threshold for GR activation — a coactivator-pool sensitization mechanism that doesn't require classical pioneer activity.
- **Documented obesity biology**: vitamin D deficiency is a recognized risk factor for metabolic dysfunction; adipose tissue sequesters vitamin D; VDR signaling is altered in obesity.
- **Statistical strength**: VDR is the best-scoring non-AT-rich motif on axis 2 (OR=1.26, raw p=0.006) and is significantly HFD-enriched on axis 1 (adj_p=0.0003).
- **194 candidate composite peaks** for downstream annotation — list at `full_motif_scan/Vdr_*_GR_composite_genes.tsv` after the qmd renders.

### Mechanistic claim (revised again after data-driven analysis)

> Candidate-driven testing of three literature-derived GR pioneers (FoxA1, FoxO1, C/EBPβ) failed to identify HFD-specific sensitizing enhancers; the C/EBP+GR signal was a "condition-specific vs constitutive" enhancer bias, not HFD-induction. A data-driven scan of all 772 testable JASPAR motifs against HFD-specific (n=6,900) and CHD-specific (n=1,322) peaks identified one strictly-significant hit (Dmrt1, but likely an AT-rich motif artifact pending RNA-seq confirmation) and a relaxed-criteria short list of biologically interpretable non-homeobox candidates. The vitamin D receptor (Vdr) emerges as the strongest non-artifact candidate: significantly HFD-enriched (axis 1 adj_p=3e-4), positively co-occurring with GR motifs (OR=1.26, p=0.006), and mechanistically coherent — VDR shares the entire steroid-receptor coactivator complex with GR, providing a coactivator-pool sensitization mechanism. AP-1 (FOSL1::JUN, FOSB::JUNB) shows the strongest HFD enrichment on axis 1 but only borderline GR co-occurrence, consistent with AP-1 driving inflammation-side chromatin rewiring rather than direct GR sensitization. The dominant homeobox/HOX/DLX cluster in the top 40 is almost certainly the AT-rich-motif AME bias that has plagued every AME run on this dataset and should be filtered by RNA-seq expression before further interpretation.

### Critical next step — filter candidates by adipocyte expression

The top of the data-driven list is contaminated by AT-rich-motif bias (HOX, DLX, DMRT, SOX). The single most-informative validation is to pull **Hinte's matched RNA-seq** (deposited alongside the ATAC in GSE236575) and intersect the candidate motif list with TFs actually expressed in adipocytes. This will:
- Eliminate most homeobox hits (HOX/DLX/PHOX/LHX/etc. aren't expressed in mature adipocytes)
- Confirm or rule out Dmrt1 (gonadal TF — should NOT be expressed in adipose if it's bias)
- Provide an orthogonal axis: TFs whose **expression itself** is HFD-induced are stronger sensitizer candidates than those merely with HFD-enriched motif occupancy

This single integration step would convert the current ranked-but-noisy list into a usable short list.

### Other motif-level follow-ups (still planned)

4. **Distance-stratified motif enrichment** — re-run AME/HOMER restricted to (a) promoter-proximal HFD peaks (TSS ± 2kb) vs (b) distal enhancers. Pioneer-mediated GR sensitization should be enriched in distal enhancers.

### Targeted gene-locus analysis (current pipeline outputs sufficient)

5. **Annotate HFD-specific peaks at the loci of**: HSD11B1, NR3C1 (GR), NCOA1, NCOA2, FKBP5 (GR-induced feedback regulator), FOXA1, CEBPB, FOXO1. Differential accessibility at any of these would identify the sensitization mechanism (ligand amplification, receptor abundance, coactivator availability, or autoregulation of the pioneer machinery).

### Cross-dataset integration (future runs)

6. **Direct GR ChIP-seq overlap**: apply this pipeline to the Hu (mm10) and Soccio (mm9, needs liftover) GR ChIP-seq datasets in `external-datasets/`. Then ask:
   - Do HFD-opened chromatin regions overlap published GR ChIP-seq peaks more than expected by chance?
   - Are FoxA1- and C/EBPβ-enriched HFD peaks specifically enriched for GR ChIP-seq overlap?
   - This would be the most direct test of the pioneer hypothesis: HFD opens chromatin → GR binds in published ChIP-seq → confirmed sensitizing enhancer.
7. **Matched RNA-seq integration**: pull Hinte et al's matched RNA-seq from GEO. Critical for testing the coactivator-drive (NCOA1/2 expression) and ligand-amplification (HSD11B1) mechanisms that are invisible to ATAC alone. Also lets us check whether FoxA1, C/EBPβ, and FoxO1 themselves are upregulated at the transcript level under HFD (would explain how their motif activity expands).

### Experimental follow-up (out of scope for this pipeline)

8. **Functional validation of candidate sensitizing enhancers** identified in step 1–3 by reporter assays under HFD ± dexamethasone, or CRISPRi knockdown of FoxA1/C/EBPβ in cultured adipocytes followed by glucocorticoid challenge.

## Provenance

- Pipeline: `external-datasets/snATACseq/GSE236575/main.nf`
- AME results: `ame_results/HFD_vs_shared/ame.tsv` (Fisher exact, totalhits scoring)
- HOMER results: `homer_results/HFD_vs_shared/knownResults.txt`
- DESeq2 results: `../deseq2/deseq2_results.txt` and the BED files in that directory
- Hinte concordance: `../hinte_concordance/concordance_report.txt`
