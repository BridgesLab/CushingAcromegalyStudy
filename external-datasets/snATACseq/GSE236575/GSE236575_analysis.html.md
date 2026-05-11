---
title: "Analysis of DESeq and MEME analysis of GSE236575"
author: "Dave Bridges"
date: "2025-11-20"
editor: source
format: 
  html:
    toc: true
    toc-location: right
    keep-md: true
    code-fold: true
    code-summary: "Show the code"
    fig-path: "figures/"
knitr:
  opts_chunk:
    fig-path: "figures/"          # folder for all figure files
    dev: ["png", "pdf"]           # both formats for every plot
    dpi: 300                      # ← this is the correct place for resolution
    dev.args:
      png:
        type: "cairo-png"         # better anti-aliasing / font rendering (optional but recommended)
      pdf:
        family: "sans"            # font family (optional)
---


::: {.cell}

```{.r .cell-code}
# hide this code chunk
#| echo: false
#| message: false

# defines the se function
se <- function(x) {
  sd(x, na.rm = TRUE) / sqrt(length(x))
}

#load these packages, nearly always needed
library(tidyverse)
```

::: {.cell-output .cell-output-stderr}

```
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.2.1     ✔ readr     2.2.0
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.3     ✔ tibble    3.3.1
✔ lubridate 1.9.5     ✔ tidyr     1.3.2
✔ purrr     1.2.2     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
```


:::

```{.r .cell-code}
# sets maize and blue color scheme
color_scheme <- c("#00274c", "#ffcb05")
```
:::


## Purpose

This script analyses the results from a DESeq2 and MEME analysis of GSE236575.  The purpose of this analysis is to identify differentially expressed regions and enriched motifs in that dataset.  See the README.md file in this folder for details on the generation of these files

## Raw Data

The DESeq2 analysis was done on the remote server (see `main.nf` for commands).  This script loads in both those results and the raw counts that were used for that analysis.  


::: {.cell}

```{.r .cell-code}
library(readr) #loads the readr package
deseq.filename <- "results/deseq2/deseq2_results.txt" #input file(s)
deseq.counts.filename <- "results/deseq2/deseq2_normalized_counts.txt"

deseq.results <- read_tsv(deseq.filename) #reads in the data
```

::: {.cell-output .cell-output-stderr}

```
Rows: 61619 Columns: 10
── Column specification ────────────────────────────────────────────────────────
Delimiter: "\t"
chr (2): chr, peak_id
dbl (8): start, end, baseMean, log2FoldChange, lfcSE, stat, pvalue, padj

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```


:::
:::


These data can be found in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/external-datasets/snATACseq/GSE236575 in a file named results/deseq2/deseq2_results.txt.  This input file was most recently updated on 2026-05-06.  This script was most recently updated on Mon May 11 12:11:19 2026.

## Analysis

There were 61619 regions analyzed in this dataset.  Of these, 14872 (24.1354128%) were found to be significantly differentially accessible comparing the NCD to HFD adipocytes at an FDR of 0.05.  Of those significant regions, 8612 (57.9074771%) were upregulated in HFD adipocytes and (42.0925229%) were more accessible in NCD adipocytes.

Out of the differentially regulated subset, the HFD adipocytes had an average log2 fold change of 1.5394525 +/- 0.0065426, while the NCD adipocytes had an average log2 fold change of -0.817636 +/- 0.0037877.


### Annotation to known genes


::: {.cell}

```{.r .cell-code}
library(ChIPseeker)
```

::: {.cell-output .cell-output-stderr}

```

```


:::

::: {.cell-output .cell-output-stderr}

```
ChIPseeker v1.48.0 Learn more at https://yulab-smu.top/contribution-knowledge-mining/

Please cite:

Qianwen Wang, Ming Li, Tianzhi Wu, Li Zhan, Lin Li, Meijun Chen, Wenqin
Xie, Zijing Xie, Erqiang Hu, Shuangbin Xu, Guangchuang Yu. Exploring
epigenomic datasets by ChIPseeker. Current Protocols. 2022, 2(10): e585
```


:::

```{.r .cell-code}
library(GenomicRanges)
```

::: {.cell-output .cell-output-stderr}

```
Loading required package: stats4
```


:::

::: {.cell-output .cell-output-stderr}

```
Loading required package: BiocGenerics
```


:::

::: {.cell-output .cell-output-stderr}

```
Loading required package: generics
```


:::

::: {.cell-output .cell-output-stderr}

```

Attaching package: 'generics'
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:lubridate':

    as.difftime
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:dplyr':

    explain
```


:::

::: {.cell-output .cell-output-stderr}

```
The following objects are masked from 'package:base':

    as.difftime, as.factor, as.ordered, intersect, is.element, setdiff,
    setequal, union
```


:::

::: {.cell-output .cell-output-stderr}

```

Attaching package: 'BiocGenerics'
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:dplyr':

    combine
```


:::

::: {.cell-output .cell-output-stderr}

```
The following objects are masked from 'package:stats':

    IQR, mad, sd, var, xtabs
```


:::

::: {.cell-output .cell-output-stderr}

```
The following objects are masked from 'package:base':

    anyDuplicated, aperm, append, as.data.frame, basename, cbind,
    colnames, dirname, do.call, duplicated, eval, evalq, Filter, Find,
    get, grep, grepl, is.unsorted, lapply, Map, mapply, match, mget,
    order, paste, pmax, pmax.int, pmin, pmin.int, Position, rank,
    rbind, Reduce, rownames, sapply, saveRDS, table, tapply, unique,
    unsplit, which.max, which.min
```


:::

::: {.cell-output .cell-output-stderr}

```
Loading required package: S4Vectors
```


:::

::: {.cell-output .cell-output-stderr}

```

Attaching package: 'S4Vectors'
```


:::

::: {.cell-output .cell-output-stderr}

```
The following objects are masked from 'package:lubridate':

    second, second<-
```


:::

::: {.cell-output .cell-output-stderr}

```
The following objects are masked from 'package:dplyr':

    first, rename
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:tidyr':

    expand
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:utils':

    findMatches
```


:::

::: {.cell-output .cell-output-stderr}

```
The following objects are masked from 'package:base':

    expand.grid, I, unname
```


:::

::: {.cell-output .cell-output-stderr}

```
Loading required package: IRanges
```


:::

::: {.cell-output .cell-output-stderr}

```

Attaching package: 'IRanges'
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:lubridate':

    %within%
```


:::

::: {.cell-output .cell-output-stderr}

```
The following objects are masked from 'package:dplyr':

    collapse, desc, slice
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:purrr':

    reduce
```


:::

::: {.cell-output .cell-output-stderr}

```
Loading required package: Seqinfo
```


:::

```{.r .cell-code}
library(TxDb.Mmusculus.UCSC.mm10.knownGene)
```

::: {.cell-output .cell-output-stderr}

```
Loading required package: GenomicFeatures
```


:::

::: {.cell-output .cell-output-stderr}

```
Loading required package: AnnotationDbi
```


:::

::: {.cell-output .cell-output-stderr}

```
Loading required package: Biobase
```


:::

::: {.cell-output .cell-output-stderr}

```
Welcome to Bioconductor

    Vignettes contain introductory material; view with
    'browseVignettes()'. To cite Bioconductor, see
    'citation("Biobase")', and for packages 'citation("pkgname")'.
```


:::

::: {.cell-output .cell-output-stderr}

```

Attaching package: 'AnnotationDbi'
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:dplyr':

    select
```


:::

```{.r .cell-code}
library(org.Mm.eg.db)
```

::: {.cell-output .cell-output-stderr}

```

```


:::

```{.r .cell-code}
# BED files from main.nf use UCSC-style chr-prefixed naming (chr1, chrM, ...)
# so deseq.results$chr is already "chr1" etc. — no extra prefixing needed.
hfd.peaks <- deseq.results |> filter(padj<0.05, log2FoldChange>0)
hfd.gr <- with(hfd.peaks, GRanges(seqnames=chr, ranges=IRanges(start+1, end))) # 0-based BED -> 1-based GRanges
txdb <- TxDb.Mmusculus.UCSC.mm10.knownGene

hfd.annot <- annotatePeak(hfd.gr, TxDb=txdb, tssRegion=c(-2000, 500), annoDb="org.Mm.eg.db")
```

::: {.cell-output .cell-output-stdout}

```
>> preparing features information...		 2026-05-11 12:11:24 
>> Using Genome: mm10 ...
>> identifying nearest features...		 2026-05-11 12:11:24 
>> calculating distance from peak to TSS...	 2026-05-11 12:11:25 
>> assigning genomic annotation...		 2026-05-11 12:11:25 
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
>> adding gene annotation...			 2026-05-11 12:11:33 
```


:::

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:many mapping between keys and columns
```


:::

::: {.cell-output .cell-output-stdout}

```
>> assigning chromosome lengths			 2026-05-11 12:11:34 
>> done...					 2026-05-11 12:11:34 
```


:::

```{.r .cell-code}
hfd.ann_df <- as.data.frame(hfd.annot)

ncd.peaks <- deseq.results |> filter(padj<0.05, log2FoldChange<0)
ncd.gr <- with(ncd.peaks, GRanges(seqnames=chr, ranges=IRanges(start+1, end)))

ncd.annot <- annotatePeak(ncd.gr, TxDb=txdb, tssRegion=c(-2000, 500), annoDb="org.Mm.eg.db")
```

::: {.cell-output .cell-output-stdout}

```
>> preparing features information...		 2026-05-11 12:11:34 
>> Using Genome: mm10 ...
>> identifying nearest features...		 2026-05-11 12:11:34 
>> calculating distance from peak to TSS...	 2026-05-11 12:11:34 
>> assigning genomic annotation...		 2026-05-11 12:11:34 
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
>> adding gene annotation...			 2026-05-11 12:11:35 
```


:::

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:many mapping between keys and columns
```


:::

::: {.cell-output .cell-output-stdout}

```
>> assigning chromosome lengths			 2026-05-11 12:11:35 
>> done...					 2026-05-11 12:11:35 
```


:::

```{.r .cell-code}
ncd.ann_df <- as.data.frame(ncd.annot)

all.gr <- with(deseq.results, GRanges(seqnames=chr, ranges=IRanges(start+1, end)))
all.ann_df <- as.data.frame(annotatePeak(all.gr, TxDb=txdb, tssRegion=c(-2000, 500), annoDb="org.Mm.eg.db"))
```

::: {.cell-output .cell-output-stdout}

```
>> preparing features information...		 2026-05-11 12:11:35 
>> Using Genome: mm10 ...
>> identifying nearest features...		 2026-05-11 12:11:35 
>> calculating distance from peak to TSS...	 2026-05-11 12:11:35 
>> assigning genomic annotation...		 2026-05-11 12:11:35 
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
>> adding gene annotation...			 2026-05-11 12:11:37 
```


:::

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:many mapping between keys and columns
```


:::

::: {.cell-output .cell-output-stdout}

```
>> assigning chromosome lengths			 2026-05-11 12:11:37 
>> done...					 2026-05-11 12:11:37 
```


:::
:::


These 8612 chromatin regions that were differentially opened by HFD were annotated as closest to 4632 unique genes, whereas the 6260 regions more accessible in NCD were annotated as closest to 3560 unique genes.  

### Volcano Plots of Regions


::: {.cell}

```{.r .cell-code}
library(ggplot2)
library(ggrepel)
# Join on chromosome AND end so peaks on different chromosomes can't collide.
# all.ann_df$seqnames == deseq.results$chr; all.ann_df$end == deseq.results$end.
deseq.results.annot <- deseq.results |>
  left_join(all.ann_df, by=c("chr"="seqnames", "end"="end"))

ggplot(deseq.results.annot, aes(x=log2FoldChange, y=-log10(pvalue))) +
  geom_point(alpha=0.4,size=1) +
  xlab("Log2 Fold Change (HFD vs NCD)") +
  ylab("-Log10 P-value") +
  ggtitle("Differentially Accessible Regions") +
  #ggrepel::geom_text_repel(
  #  data = deseq.results.annot |>
  #    filter(padj < 0.05 & abs(log2FoldChange) > 0.5) |>
  #    arrange(padj) |> head(10),
  #  aes(label = SYMBOL), size = 5, max.overlaps = Inf) +
  geom_hline(yintercept=-log10(0.05), linetype="dashed", color="red") +
  geom_vline(xintercept=c(-1, 1), linetype="dashed", color="blue") +
  theme_classic(base_size=16)
```

::: {.cell-output-display}
![](figures/volcano-regions-1.png){width=2100}
:::
:::


### GSEA Analysis of nearest genes


::: {.cell}

```{.r .cell-code}
library(clusterProfiler)
```

::: {.cell-output .cell-output-stderr}

```
clusterProfiler v4.20.0 Learn more at https://yulab-smu.top/contribution-knowledge-mining/

Please cite:

S Xu, E Hu, Y Cai, Z Xie, X Luo, L Zhan, W Tang, Q Wang, B Liu, R Wang,
W Xie, T Wu, L Xie, G Yu. Using clusterProfiler to characterize
multiomics data. Nature Protocols. 2024, 19(11):3292-3320
```


:::

::: {.cell-output .cell-output-stderr}

```

Attaching package: 'clusterProfiler'
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:AnnotationDbi':

    select
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:IRanges':

    slice
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:S4Vectors':

    rename
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:purrr':

    simplify
```


:::

::: {.cell-output .cell-output-stderr}

```
The following object is masked from 'package:stats':

    filter
```


:::

```{.r .cell-code}
hfd.gobp <- enrichGO(gene          = bitr(unique(hfd.ann_df$SYMBOL), 
                 fromType = "SYMBOL",
                 toType = "ENTREZID",
                 OrgDb = org.Mm.eg.db)$ENTREZID,
                OrgDb         = org.Mm.eg.db,
                keyType       = "ENTREZID",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.05,
                qvalueCutoff  = 0.05,
                readable      = TRUE)
```

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:1 mapping between keys and columns
```


:::

::: {.cell-output .cell-output-stderr}

```
Warning in bitr(unique(hfd.ann_df$SYMBOL), fromType = "SYMBOL", toType =
"ENTREZID", : 0.02% of input gene IDs are fail to map...
```


:::

```{.r .cell-code}
dotplot(hfd.gobp, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](figures/enrichment-hfd-1.png){width=2100}
:::

```{.r .cell-code}
barplot(hfd.gobp, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](figures/enrichment-hfd-2.png){width=2100}
:::

```{.r .cell-code}
library(enrichplot)
```

::: {.cell-output .cell-output-stderr}

```
enrichplot v1.32.0 Learn more at https://yulab-smu.top/contribution-knowledge-mining/

Please cite:

Guangchuang Yu, Li-Gen Wang, Yanyan Han and Qing-Yu He.
clusterProfiler: an R package for comparing biological themes among
gene clusters. OMICS: A Journal of Integrative Biology. 2012,
16(5):284-287
```


:::

```{.r .cell-code}
emapplot(pairwise_termsim(hfd.gobp))
```

::: {.cell-output-display}
![](figures/enrichment-hfd-3.png){width=2100}
:::

```{.r .cell-code}
#transfac
library(msigdbr)
```
:::


#### Gene Transcription Regulation Database 


::: {.cell}

```{.r .cell-code}
gtrd <- msigdbr(
    db_species="MM",
    species = "Mus musculus",
    subcollection="GTRD"
)


hfd.gobp.gtrd <- enricher(
    unique(hfd.ann_df$SYMBOL),                              # your ENTREZ or SYMBOL list
    TERM2GENE = gtrd[, c("gs_name", "gene_symbol")]
)
dotplot(hfd.gobp.gtrd, showCategory=20) + ggtitle("GTRD Enrichment")
```

::: {.cell-output-display}
![](figures/hfd-gtrd-1.png){width=2100}
:::

```{.r .cell-code}
barplot(hfd.gobp.gtrd, showCategory=20) + ggtitle("GTRD Enrichment")
```

::: {.cell-output-display}
![](figures/hfd-gtrd-2.png){width=2100}
:::

```{.r .cell-code}
#emapplot(pairwise_termsim(hfd.gobp.gtrd))
```
:::



::: {.cell}

```{.r .cell-code}
ncd.gobp <- enrichGO(gene          = bitr(unique(ncd.ann_df$SYMBOL), 
                 fromType = "SYMBOL",
                 toType = "ENTREZID",
                 OrgDb = org.Mm.eg.db)$ENTREZID,
                OrgDb         = org.Mm.eg.db,
                keyType       = "ENTREZID",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.05,
                qvalueCutoff  = 0.05,
                readable      = TRUE)
```

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:1 mapping between keys and columns
```


:::

::: {.cell-output .cell-output-stderr}

```
Warning in bitr(unique(ncd.ann_df$SYMBOL), fromType = "SYMBOL", toType =
"ENTREZID", : 0.03% of input gene IDs are fail to map...
```


:::

```{.r .cell-code}
dotplot(ncd.gobp, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](figures/enrichment-ncd-1.png){width=2100}
:::

```{.r .cell-code}
barplot(ncd.gobp, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](figures/enrichment-ncd-2.png){width=2100}
:::

```{.r .cell-code}
emapplot(pairwise_termsim(ncd.gobp))
```

::: {.cell-output-display}
![](figures/enrichment-ncd-3.png){width=2100}
:::
:::


## Pioneer + GR Composite Motif Analysis

Tests the sensitization hypothesis from `results/motif_analysis/SUMMARY.md`:
do HFD-opened peaks contain an enriched fraction of pioneer-factor + GR composite enhancers? These would be candidate sites where HFD-driven chromatin remodeling licenses GR binding that would otherwise be inaccessible.

Inputs come from the `COMPOSITE_MOTIF_SCAN` Nextflow process, which uses FIMO to scan HFD-specific and shared peak FASTAs against JASPAR 2024 motifs for FOXA1, FOXA2, CEBPA, CEBPB, FOXO1, and NR3C1.


::: {.cell}

```{.r .cell-code}
library(readr)
library(dplyr)
library(stringr)

hfd.motifs    <- read_tsv("results/motif_analysis/composite_scan/HFD_specific/HFD_specific_per_peak_motifs.tsv")
```

::: {.cell-output .cell-output-stderr}

```
Rows: 6900 Columns: 8
── Column specification ────────────────────────────────────────────────────────
Delimiter: "\t"
chr (1): peak
dbl (7): MA0102.5, MA0113.4, MA0148.5, MA0466.4, MA0480.3, MA2323.1, MA2327.1

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```


:::

```{.r .cell-code}
shared.motifs <- read_tsv("results/motif_analysis/composite_scan/shared/shared_per_peak_motifs.tsv")
```

::: {.cell-output .cell-output-stderr}

```
Rows: 53397 Columns: 8
── Column specification ────────────────────────────────────────────────────────
Delimiter: "\t"
chr (1): peak
dbl (7): MA0102.5, MA0113.4, MA0148.5, MA0466.4, MA0480.3, MA2323.1, MA2327.1

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```


:::

```{.r .cell-code}
# JASPAR ID -> friendly TF name. PGR motifs are included as GR-class proxies
# because NR3C1 (MA0113.4) is often pruned from JASPAR's non-redundant subset
# due to motif similarity with PGR/AR. PGR's IR3 motif is biochemically
# essentially identical to GR's, so we treat PGR signal as has_gr.
motif_map <- c(
  "MA0148.5" = "FOXA1",
  "MA0047.5" = "FOXA2",
  "MA0466.4" = "CEBPB",
  "MA0102.5" = "CEBPA",
  "MA0480.3" = "FOXO1",
  "MA0113.4" = "NR3C1",
  "MA2327.1" = "PGR_h",
  "MA2323.1" = "PGR_m"
)
rename_motif_cols <- function(df) {
  names(df) <- ifelse(names(df) %in% names(motif_map), motif_map[names(df)], names(df))
  df
}
hfd    <- rename_motif_cols(hfd.motifs)
shared <- rename_motif_cols(shared.motifs)

# Classify peaks by presence of pioneer/cooperator and GR motifs.
# A motif is "present" if FIMO found >= 1 occurrence within the 500-bp peak window.
classify_peaks <- function(df) {
  cols <- names(df)
  has <- function(tf) if (tf %in% cols) df[[tf]] > 0 else rep(FALSE, nrow(df))
  df$has_foxa <- has("FOXA1") | has("FOXA2")
  df$has_cebp <- has("CEBPA") | has("CEBPB")
  df$has_foxo <- has("FOXO1")
  # GR-class: NR3C1 directly, or PGR (human/mouse) as IR3 proxy
  df$has_gr   <- has("NR3C1") | has("PGR_h") | has("PGR_m")
  df$foxa_gr  <- df$has_foxa & df$has_gr
  df$cebp_gr  <- df$has_cebp & df$has_gr
  df$foxo_gr  <- df$has_foxo & df$has_gr
  df$any_pioneer    <- df$has_foxa | df$has_cebp | df$has_foxo
  df$any_pioneer_gr <- df$any_pioneer & df$has_gr
  df
}
hfd.c    <- classify_peaks(hfd)
shared.c <- classify_peaks(shared)
```
:::


### Co-occurrence Fisher tests

Is the rate of pioneer+GR co-occurrence enriched in HFD-opened peaks vs the shared background? A significant odds ratio > 1 means HFD-opened chromatin disproportionately contains composite enhancers — the direct prediction of the pioneer-mediated sensitization model.


::: {.cell}

```{.r .cell-code}
fisher_2x2 <- function(label, hfd_pos, hfd_n, sh_pos, sh_n) {
  tab <- matrix(c(hfd_pos, hfd_n - hfd_pos,
                  sh_pos,  sh_n  - sh_pos), nrow = 2)
  ft <- fisher.test(tab, alternative = "greater")
  tibble(
    comparison    = label,
    hfd_with      = hfd_pos,
    hfd_total     = hfd_n,
    hfd_pct       = round(100 * hfd_pos / hfd_n, 2),
    shared_with   = sh_pos,
    shared_total  = sh_n,
    shared_pct    = round(100 * sh_pos / sh_n, 2),
    odds_ratio    = unname(ft$estimate),
    p_value       = ft$p.value
  )
}

cooc <- bind_rows(
  fisher_2x2("FoxA + GR",  sum(hfd.c$foxa_gr), nrow(hfd.c), sum(shared.c$foxa_gr), nrow(shared.c)),
  fisher_2x2("C/EBP + GR", sum(hfd.c$cebp_gr), nrow(hfd.c), sum(shared.c$cebp_gr), nrow(shared.c)),
  fisher_2x2("FoxO + GR",  sum(hfd.c$foxo_gr), nrow(hfd.c), sum(shared.c$foxo_gr), nrow(shared.c)),
  fisher_2x2("Any pioneer + GR", sum(hfd.c$any_pioneer_gr), nrow(hfd.c), sum(shared.c$any_pioneer_gr), nrow(shared.c))
)
knitr::kable(cooc, digits = c(0,0,0,2,0,0,2,3,4))
```

::: {.cell-output-display}


|comparison       | hfd_with| hfd_total| hfd_pct| shared_with| shared_total| shared_pct| odds_ratio| p_value|
|:----------------|--------:|---------:|-------:|-----------:|------------:|----------:|----------:|-------:|
|FoxA + GR        |      115|      6900|    1.67|         833|        53397|       1.56|      1.070|  0.2654|
|C/EBP + GR       |      310|      6900|    4.49|        1718|        53397|       3.22|      1.415|  0.0000|
|FoxO + GR        |      115|      6900|    1.67|         834|        53397|       1.56|      1.068|  0.2694|
|Any pioneer + GR |      400|      6900|    5.80|        2412|        53397|       4.52|      1.301|  0.0000|


:::
:::


### Gene annotation of candidate sensitizing enhancers

For HFD-opened peaks containing both a pioneer motif and a GR motif, annotate to the nearest TSS — these are candidate genes whose chromatin opening under HFD may license potentiated GR binding.


::: {.cell}

```{.r .cell-code}
parse_peaks_to_gr <- function(peak_ids) {
  m <- str_match(peak_ids, "^(.+):(\\d+)-(\\d+)$")
  GRanges(
    seqnames = m[, 2],
    ranges = IRanges(start = as.integer(m[, 3]) + 1, end = as.integer(m[, 4]))
  )
}

annotate_composite <- function(df, field, label) {
  peaks <- df %>% filter(.data[[field]]) %>% pull(peak)
  if (length(peaks) == 0) return(tibble())
  gr <- parse_peaks_to_gr(peaks)
  ann <- annotatePeak(
    gr,
    TxDb = TxDb.Mmusculus.UCSC.mm10.knownGene,
    tssRegion = c(-2000, 500),
    annoDb = "org.Mm.eg.db",
    verbose = FALSE
  )
  as.data.frame(ann) %>%
    mutate(composite = label) %>%
    arrange(abs(distanceToTSS))
}

foxa_gr.ann <- annotate_composite(hfd.c, "foxa_gr",  "FoxA + GR")
```

::: {.cell-output .cell-output-stdout}

```
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
```


:::

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:1 mapping between keys and columns
```


:::

```{.r .cell-code}
cebp_gr.ann <- annotate_composite(hfd.c, "cebp_gr",  "C/EBP + GR")
```

::: {.cell-output .cell-output-stdout}

```
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
```


:::

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:1 mapping between keys and columns
```


:::

```{.r .cell-code}
foxo_gr.ann <- annotate_composite(hfd.c, "foxo_gr",  "FoxO + GR")
```

::: {.cell-output .cell-output-stdout}

```
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
>> Using Genome: mm10 ...
```


:::

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:1 mapping between keys and columns
```


:::
:::


#### Top candidate genes — FoxA + GR composite peaks

FoxA1 is the canonical GR pioneer in steroid-responsive tissues. Genes near FoxA+GR composite enhancers in HFD-opened chromatin are the highest-priority candidates for HFD-driven GR sensitization.


::: {.cell}

```{.r .cell-code}
foxa_gr.top <- foxa_gr.ann %>%
  filter(!is.na(SYMBOL)) %>%
  distinct(SYMBOL, .keep_all = TRUE) %>%
  arrange(abs(distanceToTSS)) %>%
  select(SYMBOL, distanceToTSS, annotation, seqnames, start, end) %>%
  head(40)
knitr::kable(foxa_gr.top)
```

::: {.cell-output-display}


|SYMBOL        | distanceToTSS|annotation                                                        |seqnames |     start|       end|
|:-------------|-------------:|:-----------------------------------------------------------------|:--------|---------:|---------:|
|Med27         |             0|Promoter (<=1kb)                                                  |chr2     |  29391051|  29391550|
|Actr3         |            84|Promoter (<=1kb)                                                  |chr1     | 125397029| 125397528|
|Hmcn1         |           680|Intron (ENSMUST00000074783.11/545370, intron 1 of 106)            |chr1     | 150991872| 150992371|
|D16Ertd472e   |          1299|Exon (ENSMUST00000232329.1/67102, exon 2 of 3)                    |chr16    |  78558446|  78558945|
|Trim16        |         -1676|Promoter (1-2kb)                                                  |chr11    |  62831625|  62832124|
|Tsg101        |          1811|Intron (ENSMUST00000014546.14/22088, intron 2 of 9)               |chr7     |  46912100|  46912599|
|Gcfc2         |          1884|3' UTR                                                            |chr6     |  81943238|  81943737|
|Sgip1         |          2155|Exon (ENSMUST00000066824.13/73094, exon 20 of 24)                 |chr4     | 102964511| 102965010|
|Pcdh1         |         -2297|Intron (ENSMUST00000160721.7/75599, intron 1 of 4)                |chr18    |  38206137|  38206636|
|Oas3          |         -2435|Intron (ENSMUST00000201006.1/ENSMUST00000201006.1, intron 1 of 2) |chr5     | 120780096| 120780595|
|A630001G21Rik |          2847|Intron (ENSMUST00000159320.7/319997, intron 1 of 5)               |chr1     |  85733208|  85733707|
|Popdc1        |         -3007|Intron (ENSMUST00000095715.4/23828, intron 5 of 7)                |chr10    |  45350002|  45350501|
|Arhgap1       |         -3107|Intron (ENSMUST00000111329.7/228359, intron 5 of 13)              |chr2     |  91664910|  91665409|
|Ezr           |         -3248|Intron (ENSMUST00000064234.6/22350, intron 7 of 12)               |chr17    |   6746069|   6746568|
|Ankfn1        |         -3574|Intron (ENSMUST00000238273.2/382543, intron 2 of 21)              |chr11    |  89781227|  89781726|
|Cntn1         |          4487|Intron (ENSMUST00000141187.7/12805, intron 1 of 8)                |chr15    |  92165844|  92166343|
|Ankrd44       |          5026|Intron (ENSMUST00000179030.7/329154, intron 26 of 27)             |chr1     |  54652162|  54652661|
|Hipk1         |         -6169|Intron (ENSMUST00000118317.7/15257, intron 8 of 15)               |chr3     | 103757183| 103757682|
|Ctsl          |          7367|3' UTR                                                            |chr13    |  64359189|  64359688|
|Crim1         |          7576|Intron (ENSMUST00000112498.2/50766, intron 4 of 16)               |chr17    |  78287759|  78288258|
|Prdm2         |         -7779|Distal Intergenic                                                 |chr4     | 143220774| 143221273|
|4930519L02Rik |          9943|Exon (ENSMUST00000200254.1/102636203, exon 5 of 5)                |chr3     | 143040557| 143041056|
|Pcca          |        -10036|Intron (ENSMUST00000148172.1/110821, intron 4 of 4)               |chr14    | 122572149| 122572648|
|Efcab2        |         10090|Intron (ENSMUST00000194861.1/68226, intron 1 of 2)                |chr1     | 178416193| 178416692|
|Tmem17        |        -11080|Distal Intergenic                                                 |chr11    |  22500509|  22501008|
|Cyp4b1        |        -11280|Distal Intergenic                                                 |chr4     | 115659003| 115659502|
|Ccdc141       |        -11605|3' UTR                                                            |chr2     |  77182241|  77182740|
|Qrfprl        |         12241|Intron (ENSMUST00000170608.7/243407, intron 4 of 5)               |chr6     |  65453545|  65454044|
|Baalc         |        -12589|Distal Intergenic                                                 |chr15    |  38920056|  38920555|
|Lrp2bp        |         14142|Intron (ENSMUST00000170416.7/102141, intron 15 of 17)             |chr8     |  46036622|  46037121|
|Gm10421       |        -14781|Intron (ENSMUST00000190247.6/19276, intron 13 of 22)              |chr12    | 117166050| 117166549|
|Il34          |         15840|Intron (ENSMUST00000150680.1/76527, intron 1 of 7)                |chr8     | 110774549| 110775048|
|Pam           |         16510|Intron (ENSMUST00000058762.14/18484, intron 3 of 25)              |chr1     |  97960059|  97960558|
|1700001G01Rik |        -16533|Intron (ENSMUST00000147119.7/75433, intron 1 of 2)                |chr18    |  17108755|  17109254|
|Spats2l       |        -16741|Intron (ENSMUST00000172287.7/67198, intron 6 of 6)                |chr1     |  57884831|  57885330|
|Trim24        |        -17436|Distal Intergenic                                                 |chr6     |  37852876|  37853375|
|Gm5089        |        -17517|Distal Intergenic                                                 |chr14    | 122424260| 122424759|
|Dcbld2        |        -18589|Distal Intergenic                                                 |chr16    |  58389355|  58389854|
|Lnx1          |         19339|Intron (ENSMUST00000113531.8/16924, intron 3 of 12)               |chr5     |  74657791|  74658290|
|Ldlrad4       |        -19614|Intron (ENSMUST00000063775.4/52662, intron 3 of 5)                |chr18    |  68207954|  68208453|


:::
:::


#### Top candidate genes — C/EBP + GR composite peaks

C/EBPβ is the established adipocyte GR pioneer (Madsen 2014; Siersbæk 2011).


::: {.cell}

```{.r .cell-code}
cebp_gr.top <- cebp_gr.ann %>%
  filter(!is.na(SYMBOL)) %>%
  distinct(SYMBOL, .keep_all = TRUE) %>%
  arrange(abs(distanceToTSS)) %>%
  select(SYMBOL, distanceToTSS, annotation, seqnames, start, end) %>%
  head(40)
knitr::kable(cebp_gr.top)
```

::: {.cell-output-display}


|SYMBOL        | distanceToTSS|annotation                                                        |seqnames |     start|       end|
|:-------------|-------------:|:-----------------------------------------------------------------|:--------|---------:|---------:|
|1700003L19Rik |           -20|Promoter (<=1kb)                                                  |chr16    |  12810871|  12811370|
|Vmn1r180      |          -419|Promoter (<=1kb)                                                  |chr7     |  23949714|  23950213|
|Palb2         |           495|Promoter (<=1kb)                                                  |chr7     | 122123451| 122123950|
|Pdlim1        |          -559|Promoter (<=1kb)                                                  |chr19    |  40231364|  40231863|
|Rab23         |           628|3' UTR                                                            |chr1     |  33738765|  33739264|
|Cyp4a10       |           882|Exon (ENSMUST00000058785.9/13117, exon 2 of 13)                   |chr4     | 115519170| 115519669|
|Or1ab2        |         -1151|Promoter (1-2kb)                                                  |chr8     |  72105390|  72105889|
|Obsl1         |         -1869|Promoter (1-2kb)                                                  |chr1     |  75494936|  75495435|
|Gcfc2         |          1884|3' UTR                                                            |chr6     |  81943238|  81943737|
|Fpr2          |          1984|Intron (ENSMUST00000149944.1/14289, intron 1 of 2)                |chr17    |  17889872|  17890371|
|Kncn          |         -2031|Distal Intergenic                                                 |chr4     | 115881870| 115882369|
|2310002D06Rik |         -2080|Distal Intergenic                                                 |chr12    |  80504627|  80505126|
|Tsen15        |          2191|Distal Intergenic                                                 |chr1     | 152369392| 152369891|
|Dnajc6        |         -2852|Intron (ENSMUST00000154120.8/72685, intron 1 of 11)               |chr4     | 101504520| 101505019|
|Pde4d         |         -3005|Intron (ENSMUST00000122041.7/238871, intron 3 of 16)              |chr13    | 109577901| 109578400|
|Cobl          |         -3102|Intron (ENSMUST00000172919.7/12808, intron 2 of 7)                |chr11    |  12381380|  12381879|
|Ms4a15        |         -3164|Distal Intergenic                                                 |chr19    |  10996414|  10996913|
|Il16          |         -3352|Intron (ENSMUST00000001792.11/16170, intron 12 of 18)             |chr7     |  83658847|  83659346|
|Setd3         |          3516|Intron (ENSMUST00000071095.13/52690, intron 4 of 12)              |chr12    | 108158994| 108159493|
|Zfp1003       |          3522|Intron (ENSMUST00000108935.7/665205, intron 1 of 2)               |chr2     | 177900618| 177901117|
|Gm36283       |         -4133|Intron (ENSMUST00000217857.1/102640148, intron 1 of 2)            |chr10    | 108432033| 108432532|
|Cntn1         |          4487|Intron (ENSMUST00000141187.7/12805, intron 1 of 8)                |chr15    |  92165844|  92166343|
|Acbd3         |          5114|Intron (ENSMUST00000027780.5/170760, intron 3 of 7)               |chr1     | 180734971| 180735470|
|Psd3          |          5448|Intron (ENSMUST00000127631.1/ENSMUST00000127631.1, intron 2 of 3) |chr8     |  67968627|  67969126|
|Cul5          |          5461|Intron (ENSMUST00000166367.7/75717, intron 6 of 17)               |chr9     |  53640852|  53641351|
|Impact        |         -5521|Intron (ENSMUST00000234763.1/16210, intron 1 of 5)                |chr18    |  12965903|  12966402|
|Rmnd5a        |         -5658|Distal Intergenic                                                 |chr6     |  71446295|  71446794|
|Tbl1xr1       |         -5927|Intron (ENSMUST00000193734.5/81004, intron 11 of 16)              |chr3     |  22196766|  22197265|
|Hipk1         |         -6169|Intron (ENSMUST00000118317.7/15257, intron 8 of 15)               |chr3     | 103757183| 103757682|
|Ggta1         |         -6419|Intron (ENSMUST00000113002.8/14594, intron 1 of 7)                |chr2     |  35452252|  35452751|
|Stim2         |          6798|Intron (ENSMUST00000117661.8/116873, intron 1 of 11)              |chr5     |  54005363|  54005862|
|Stxbp6        |          6995|Intron (ENSMUST00000053768.13/217517, intron 2 of 5)              |chr12    |  45005470|  45005969|
|Dhx15         |          7050|3' UTR                                                            |chr5     |  52150254|  52150753|
|Snapc1        |          7145|Intron (ENSMUST00000021532.5/75627, intron 8 of 9)                |chr12    |  73979041|  73979540|
|Hivep3        |          7262|Intron (ENSMUST00000106307.8/16656, intron 4 of 8)                |chr4     | 120101751| 120102250|
|Emilin2       |         -7534|Intron (ENSMUST00000233188.1/ENSMUST00000233188.1, intron 1 of 2) |chr17    |  71319090|  71319589|
|Smap2         |          7589|Intron (ENSMUST00000043200.7/69780, intron 1 of 9)                |chr4     | 121009159| 121009658|
|Prdm2         |         -7779|Distal Intergenic                                                 |chr4     | 143220774| 143221273|
|Sh2d4a        |         -7986|Distal Intergenic                                                 |chr8     |  68268082|  68268581|
|Fmn1          |          8410|Intron (ENSMUST00000099576.8/14260, intron 4 of 18)               |chr2     | 113449474| 113449973|


:::
:::


#### Pathway enrichment of FoxA + GR composite genes


::: {.cell}

```{.r .cell-code}
foxa_gr.symbols <- foxa_gr.ann %>%
  filter(!is.na(SYMBOL)) %>%
  pull(SYMBOL) %>%
  unique()

if (length(foxa_gr.symbols) >= 10) {
  foxa_gr.entrez <- bitr(foxa_gr.symbols,
                         fromType = "SYMBOL",
                         toType   = "ENTREZID",
                         OrgDb    = org.Mm.eg.db)$ENTREZID
  foxa_gr.gobp <- enrichGO(gene          = foxa_gr.entrez,
                           OrgDb         = org.Mm.eg.db,
                           keyType       = "ENTREZID",
                           ont           = "BP",
                           pAdjustMethod = "BH",
                           pvalueCutoff  = 0.05,
                           qvalueCutoff  = 0.05,
                           readable      = TRUE)
  if (!is.null(foxa_gr.gobp) && nrow(as.data.frame(foxa_gr.gobp)) > 0) {
    dotplot(foxa_gr.gobp, showCategory = 20) + ggtitle("FoxA + GR composite genes — GO-BP")
  }
}
```

::: {.cell-output .cell-output-stderr}

```
'select()' returned 1:1 mapping between keys and columns
```


:::
:::


### Sanity check on key GR-pathway genes

Quick look at whether known glucocorticoid-sensitization genes appear in our composite-peak gene lists:


::: {.cell}

```{.r .cell-code}
gr_pathway_genes <- c("Hsd11b1", "Nr3c1", "Ncoa1", "Ncoa2", "Fkbp5",
                      "Foxa1", "Foxa2", "Cebpb", "Cebpa", "Foxo1","Pnpla2",
                      "Tsc22d3", "Per1", "Zbtb16", "Klf15", "Angptl4")
all_composite_genes <- bind_rows(foxa_gr.ann, cebp_gr.ann, foxo_gr.ann) %>%
  filter(!is.na(SYMBOL))
sanity <- tibble(gene = gr_pathway_genes) %>%
  rowwise() %>%
  mutate(
    foxa_gr = gene %in% foxa_gr.ann$SYMBOL,
    cebp_gr = gene %in% cebp_gr.ann$SYMBOL,
    foxo_gr = gene %in% foxo_gr.ann$SYMBOL
  ) %>%
  ungroup()
knitr::kable(sanity)
```

::: {.cell-output-display}


|gene    |foxa_gr |cebp_gr |foxo_gr |
|:-------|:-------|:-------|:-------|
|Hsd11b1 |FALSE   |FALSE   |FALSE   |
|Nr3c1   |FALSE   |FALSE   |FALSE   |
|Ncoa1   |FALSE   |FALSE   |FALSE   |
|Ncoa2   |FALSE   |FALSE   |FALSE   |
|Fkbp5   |FALSE   |FALSE   |FALSE   |
|Foxa1   |FALSE   |FALSE   |FALSE   |
|Foxa2   |FALSE   |FALSE   |FALSE   |
|Cebpb   |FALSE   |FALSE   |FALSE   |
|Cebpa   |FALSE   |FALSE   |FALSE   |
|Foxo1   |FALSE   |FALSE   |FALSE   |
|Pnpla2  |FALSE   |FALSE   |FALSE   |
|Tsc22d3 |FALSE   |FALSE   |FALSE   |
|Per1    |FALSE   |FALSE   |FALSE   |
|Zbtb16  |FALSE   |FALSE   |FALSE   |
|Klf15   |FALSE   |FALSE   |FALSE   |
|Angptl4 |FALSE   |FALSE   |FALSE   |


:::
:::


## Session Information


::: {.cell}

```{.r .cell-code}
sessionInfo()
```

::: {.cell-output .cell-output-stdout}

```
R version 4.6.0 (2026-04-24)
Platform: aarch64-apple-darwin23
Running under: macOS Tahoe 26.4.1

Matrix products: default
BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: America/Detroit
tzcode source: internal

attached base packages:
[1] stats4    stats     graphics  grDevices utils     datasets  methods  
[8] base     

other attached packages:
 [1] msigdbr_26.1.0                           
 [2] enrichplot_1.32.0                        
 [3] clusterProfiler_4.20.0                   
 [4] ggrepel_0.9.8                            
 [5] org.Mm.eg.db_3.23.0                      
 [6] TxDb.Mmusculus.UCSC.mm10.knownGene_3.10.0
 [7] GenomicFeatures_1.64.0                   
 [8] AnnotationDbi_1.74.0                     
 [9] Biobase_2.72.0                           
[10] GenomicRanges_1.64.0                     
[11] Seqinfo_1.2.0                            
[12] IRanges_2.46.0                           
[13] S4Vectors_0.50.0                         
[14] BiocGenerics_0.58.0                      
[15] generics_0.1.4                           
[16] ChIPseeker_1.48.0                        
[17] lubridate_1.9.5                          
[18] forcats_1.0.1                            
[19] stringr_1.6.0                            
[20] dplyr_1.2.1                              
[21] purrr_1.2.2                              
[22] readr_2.2.0                              
[23] tidyr_1.3.2                              
[24] tibble_3.3.1                             
[25] ggplot2_4.0.3                            
[26] tidyverse_2.0.0                          

loaded via a namespace (and not attached):
  [1] RColorBrewer_1.1-3                      
  [2] rstudioapi_0.18.0                       
  [3] jsonlite_2.0.0                          
  [4] tidydr_0.0.6                            
  [5] magrittr_2.0.5                          
  [6] ggtangle_0.1.2                          
  [7] farver_2.1.2                            
  [8] rmarkdown_2.31                          
  [9] fs_2.1.0                                
 [10] BiocIO_1.22.0                           
 [11] vctrs_0.7.3                             
 [12] memoise_2.0.1                           
 [13] Rsamtools_2.28.0                        
 [14] RCurl_1.98-1.18                         
 [15] ggtree_4.2.0                            
 [16] htmltools_0.5.9                         
 [17] S4Arrays_1.12.0                         
 [18] TxDb.Hsapiens.UCSC.hg19.knownGene_3.22.1
 [19] plotrix_3.8-14                          
 [20] curl_7.1.0                              
 [21] SparseArray_1.12.2                      
 [22] gridGraphics_0.5-1                      
 [23] KernSmooth_2.23-26                      
 [24] htmlwidgets_1.6.4                       
 [25] httr2_1.2.2                             
 [26] plyr_1.8.9                              
 [27] cachem_1.1.0                            
 [28] GenomicAlignments_1.48.0                
 [29] igraph_2.3.1                            
 [30] lifecycle_1.0.5                         
 [31] pkgconfig_2.0.3                         
 [32] gson_0.1.0                              
 [33] Matrix_1.7-5                            
 [34] R6_2.6.1                                
 [35] fastmap_1.2.0                           
 [36] MatrixGenerics_1.24.0                   
 [37] digest_0.6.39                           
 [38] aplot_0.2.9                             
 [39] ggnewscale_0.5.2                        
 [40] aisdk_1.1.0                             
 [41] patchwork_1.3.2                         
 [42] RSQLite_3.52.0                          
 [43] labeling_0.4.3                          
 [44] timechange_0.4.0                        
 [45] polyclip_1.10-7                         
 [46] httr_1.4.8                              
 [47] abind_1.4-8                             
 [48] compiler_4.6.0                          
 [49] bit64_4.8.0                             
 [50] fontquiver_0.2.1                        
 [51] withr_3.0.2                             
 [52] S7_0.2.2                                
 [53] BiocParallel_1.46.0                     
 [54] DBI_1.3.0                               
 [55] gplots_3.3.0                            
 [56] ggforce_0.5.0                           
 [57] MASS_7.3-65                             
 [58] rappdirs_0.3.4                          
 [59] DelayedArray_0.38.1                     
 [60] rjson_0.2.23                            
 [61] caTools_1.18.3                          
 [62] gtools_3.9.5                            
 [63] tools_4.6.0                             
 [64] otel_0.2.0                              
 [65] scatterpie_0.2.6                        
 [66] ape_5.8-1                               
 [67] glue_1.8.1                              
 [68] callr_3.7.6                             
 [69] restfulr_0.0.16                         
 [70] nlme_3.1-169                            
 [71] GOSemSim_2.38.0                         
 [72] grid_4.6.0                              
 [73] cluster_2.1.8.2                         
 [74] reshape2_1.4.5                          
 [75] gtable_0.3.6                            
 [76] tzdb_0.5.0                              
 [77] hms_1.1.4                               
 [78] XVector_0.52.0                          
 [79] pillar_1.11.1                           
 [80] babelgene_22.9                          
 [81] yulab.utils_0.2.4                       
 [82] vroom_1.7.1                             
 [83] splines_4.6.0                           
 [84] tweenr_2.0.3                            
 [85] treeio_1.36.1                           
 [86] lattice_0.22-9                          
 [87] rtracklayer_1.72.0                      
 [88] bit_4.6.0                               
 [89] tidyselect_1.2.1                        
 [90] fontLiberation_0.1.0                    
 [91] GO.db_3.23.1                            
 [92] Biostrings_2.80.0                       
 [93] knitr_1.51                              
 [94] fontBitstreamVera_0.1.1                 
 [95] SummarizedExperiment_1.42.0             
 [96] xfun_0.57                               
 [97] matrixStats_1.5.0                       
 [98] stringi_1.8.7                           
 [99] UCSC.utils_1.8.0                        
[100] lazyeval_0.2.3                          
[101] ggfun_0.2.0                             
[102] yaml_2.3.12                             
[103] boot_1.3-32                             
[104] evaluate_1.0.5                          
[105] codetools_0.2-20                        
[106] cigarillo_1.2.0                         
[107] qvalue_2.44.0                           
[108] gdtools_0.5.0                           
[109] ggplotify_0.1.3                         
[110] cli_3.6.6                               
[111] systemfonts_1.3.2                       
[112] processx_3.9.0                          
[113] Rcpp_1.1.1-1.1                          
[114] GenomeInfoDb_1.48.0                     
[115] png_0.1-9                               
[116] XML_3.99-0.23                           
[117] parallel_4.6.0                          
[118] assertthat_0.2.1                        
[119] blob_1.3.0                              
[120] DOSE_4.6.0                              
[121] bitops_1.0-9                            
[122] tidytree_0.4.7                          
[123] ggiraph_0.9.6                           
[124] enrichit_0.1.4                          
[125] scales_1.4.0                            
[126] crayon_1.5.3                            
[127] rlang_1.2.0                             
[128] KEGGREST_1.52.0                         
```


:::
:::

