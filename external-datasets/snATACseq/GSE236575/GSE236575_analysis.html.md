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
  gfm:
    html-math-method: webtex
theme: journal
execute:
  echo: true
  warning: false
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

# sets maize and blue color scheme
color_scheme <- c("#00274c", "#ffcb05")
```
:::


## Purpose

This script analyses the results from a DESeq2 and MEME analysis of GSE236575.  The purpose of this analysis is to identify differentially expressed regions and enriched motifs in that dataset.  See the README.md file in this folder for details on the generation of these files

## Raw Data

Describe your raw data files, including what the columns mean (and what units they are in).


::: {.cell}

```{.r .cell-code}
library(readr) #loads the readr package
deseq.filename <- "results/deseq2/deseq2_results.txt" #input file(s)
deseq.counts.filename <- "results/deseq2/deseq2_counts.txt"

deseq.results <- read_tsv(deseq.filename) #reads in the data
```
:::


These data can be found in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/external-datasets/snATACseq/GSE236575 in a file named results/deseq2/deseq2_results.txt.  This input file was most recently updated on 2025-11-20.  This script was most recently updated on Thu Nov 20 09:38:59 2025.

## Analysis

There were 59586 regions analyzed in this dataset.  Of these, 14754 (24.7608499%) were found to be significantly differentially accessible comparing the NCD to HFD adipocytes at an FDR of 0.05.  Of those significant regions, 7530 (51.0370069%) were upregulated in HFD adipocytes and (48.9629931%) were more accessible in NCD adipocytes.

Out of the differentially regulated subset, the HFD adipocytes had an average log2 fold change of 1.0674128 +/- 0.0044553, while the NCD adipocytes had an average log2 fold change of -0.7118612 +/- 0.0026831.

### Volcano Plots of Regions


::: {.cell}

```{.r .cell-code}
library(ggplot2)
ggplot(deseq.results, aes(x=log2FoldChange, y=-log10(pvalue))) +
  geom_point(alpha=0.4) +
  theme_minimal() +
  xlab("Log2 Fold Change (HFD vs NCD)") +
  ylab("-Log10 P-value") +
  ggtitle("Differentially Accessible Regions") +
  geom_hline(yintercept=-log10(0.05), linetype="dashed", color="red") +
  geom_vline(xintercept=c(-1, 1), linetype="dashed", color="blue") +
  theme_classic(base_size=16)
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/volcano-regions-1.png){width=672}
:::
:::

### Annotation to known genes


::: {.cell}

```{.r .cell-code}
library(ChIPseeker)
library(GenomicRanges)
library(TxDb.Mmusculus.UCSC.mm10.knownGene)
library(org.Mm.eg.db)

hfd.peaks <- deseq.results |> filter(padj<0.05,log2FoldChange>0) |>
  mutate(chr.2 = paste0("chr", chr))
hfd.gr <- with(hfd.peaks, GRanges(seqnames=chr.2, ranges=IRanges(start+1, end))) # if 0-based BED; add +1 to start for GRanges
txdb <- TxDb.Mmusculus.UCSC.mm10.knownGene

# Annotate peaks
hfd.annot <- annotatePeak(hfd.gr, TxDb=txdb, tssRegion=c(-2000, 500), annoDb="org.Mm.eg.db")
```

::: {.cell-output .cell-output-stdout}

```
>> preparing features information...		 2025-11-20 09:39:05 
>> identifying nearest features...		 2025-11-20 09:39:05 
>> calculating distance from peak to TSS...	 2025-11-20 09:39:06 
>> assigning genomic annotation...		 2025-11-20 09:39:06 
>> adding gene annotation...			 2025-11-20 09:39:15 
```


:::

::: {.cell-output .cell-output-stdout}

```
>> assigning chromosome lengths			 2025-11-20 09:39:15 
>> done...					 2025-11-20 09:39:15 
```


:::

```{.r .cell-code}
# Save annotation table with gene symbols and distance to TSS
hfd.ann_df <- as.data.frame(hfd.annot)

ncd.peaks <- deseq.results |> filter(padj<0.05,log2FoldChange<0) |>
  mutate(chr.2 = paste0("chr", chr))
ncd.gr <- with(ncd.peaks, GRanges(seqnames=chr.2, ranges=IRanges(start+1, end))) # if 0-based BED; add +1 to start for GRanges

# Annotate peaks
ncd.annot <- annotatePeak(ncd.gr, TxDb=txdb, tssRegion=c(-2000, 500), annoDb="org.Mm.eg.db")
```

::: {.cell-output .cell-output-stdout}

```
>> preparing features information...		 2025-11-20 09:39:15 
>> identifying nearest features...		 2025-11-20 09:39:15 
>> calculating distance from peak to TSS...	 2025-11-20 09:39:15 
>> assigning genomic annotation...		 2025-11-20 09:39:15 
>> adding gene annotation...			 2025-11-20 09:39:16 
```


:::

::: {.cell-output .cell-output-stdout}

```
>> assigning chromosome lengths			 2025-11-20 09:39:16 
>> done...					 2025-11-20 09:39:16 
```


:::

```{.r .cell-code}
# Save annotation table with gene symbols and distance to TSS
ncd.ann_df <- as.data.frame(ncd.annot)
```
:::


These 7530 chromatin regions that were differentially opened by HFD were annotated as closest to 4128 unique genes, whereas the 7224 regions more accessible in NCD were annotated as closest to 4602 unique genes.  

### GSEA Analysis of nearest genes


::: {.cell}

```{.r .cell-code}
library(clusterProfiler)

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

dotplot(hfd.gobp, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/enrichment-hfd-1.png){width=672}
:::

```{.r .cell-code}
barplot(hfd.gobp, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/enrichment-hfd-2.png){width=672}
:::

```{.r .cell-code}
library(enrichplot)
emapplot(pairwise_termsim(hfd.gobp))
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/enrichment-hfd-3.png){width=672}
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
dotplot(hfd.gobp.gtrd, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/hfd-gtrd-1.png){width=672}
:::

```{.r .cell-code}
barplot(hfd.gobp.gtrd, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/hfd-gtrd-2.png){width=672}
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

dotplot(ncd.gobp, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/enrichment-ncd-1.png){width=672}
:::

```{.r .cell-code}
barplot(ncd.gobp, showCategory=20) + ggtitle("GO-BP Enrichment")
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/enrichment-ncd-2.png){width=672}
:::

```{.r .cell-code}
emapplot(pairwise_termsim(ncd.gobp))
```

::: {.cell-output-display}
![](GSE236575_analysis_files/figure-html/enrichment-ncd-3.png){width=672}
:::
:::


## Interpretation

A brief summary of what the interpretation of these results were

## References

If needed you will need a *.bib file.  See the details at <https://quarto.org/docs/authoring/citations.html>

## Session Information


::: {.cell}

```{.r .cell-code}
sessionInfo()
```

::: {.cell-output .cell-output-stdout}

```
R version 4.5.2 (2025-10-31)
Platform: aarch64-apple-darwin20
Running under: macOS Tahoe 26.1

Matrix products: default
BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: America/Detroit
tzcode source: internal

attached base packages:
[1] stats4    stats     graphics  grDevices utils     datasets  methods  
[8] base     

other attached packages:
 [1] msigdbr_25.1.1                           
 [2] enrichplot_1.28.4                        
 [3] clusterProfiler_4.16.0                   
 [4] org.Mm.eg.db_3.21.0                      
 [5] TxDb.Mmusculus.UCSC.mm10.knownGene_3.10.0
 [6] GenomicFeatures_1.60.0                   
 [7] AnnotationDbi_1.70.0                     
 [8] Biobase_2.68.0                           
 [9] GenomicRanges_1.60.0                     
[10] GenomeInfoDb_1.44.3                      
[11] IRanges_2.42.0                           
[12] S4Vectors_0.46.0                         
[13] BiocGenerics_0.54.1                      
[14] generics_0.1.4                           
[15] ChIPseeker_1.44.0                        
[16] lubridate_1.9.4                          
[17] forcats_1.0.1                            
[18] stringr_1.6.0                            
[19] dplyr_1.1.4                              
[20] purrr_1.2.0                              
[21] readr_2.1.6                              
[22] tidyr_1.3.1                              
[23] tibble_3.3.0                             
[24] ggplot2_4.0.1                            
[25] tidyverse_2.0.0                          

loaded via a namespace (and not attached):
  [1] RColorBrewer_1.1-3                     
  [2] rstudioapi_0.17.1                      
  [3] jsonlite_2.0.0                         
  [4] magrittr_2.0.4                         
  [5] ggtangle_0.0.8                         
  [6] farver_2.1.2                           
  [7] rmarkdown_2.30                         
  [8] fs_1.6.6                               
  [9] BiocIO_1.18.0                          
 [10] vctrs_0.6.5                            
 [11] memoise_2.0.1                          
 [12] Rsamtools_2.24.1                       
 [13] RCurl_1.98-1.17                        
 [14] ggtree_3.16.3                          
 [15] htmltools_0.5.8.1                      
 [16] S4Arrays_1.8.1                         
 [17] TxDb.Hsapiens.UCSC.hg19.knownGene_3.2.2
 [18] plotrix_3.8-13                         
 [19] curl_7.0.0                             
 [20] SparseArray_1.8.1                      
 [21] gridGraphics_0.5-1                     
 [22] KernSmooth_2.23-26                     
 [23] htmlwidgets_1.6.4                      
 [24] plyr_1.8.9                             
 [25] cachem_1.1.0                           
 [26] GenomicAlignments_1.44.0               
 [27] igraph_2.2.1                           
 [28] lifecycle_1.0.4                        
 [29] pkgconfig_2.0.3                        
 [30] gson_0.1.0                             
 [31] Matrix_1.7-4                           
 [32] R6_2.6.1                               
 [33] fastmap_1.2.0                          
 [34] GenomeInfoDbData_1.2.14                
 [35] MatrixGenerics_1.20.0                  
 [36] digest_0.6.38                          
 [37] aplot_0.2.9                            
 [38] patchwork_1.3.2                        
 [39] RSQLite_2.4.4                          
 [40] labeling_0.4.3                         
 [41] timechange_0.3.0                       
 [42] httr_1.4.7                             
 [43] abind_1.4-8                            
 [44] compiler_4.5.2                         
 [45] bit64_4.6.0-1                          
 [46] withr_3.0.2                            
 [47] S7_0.2.1                               
 [48] BiocParallel_1.42.2                    
 [49] DBI_1.2.3                              
 [50] gplots_3.2.0                           
 [51] R.utils_2.13.0                         
 [52] rappdirs_0.3.3                         
 [53] DelayedArray_0.34.1                    
 [54] rjson_0.2.23                           
 [55] caTools_1.18.3                         
 [56] gtools_3.9.5                           
 [57] tools_4.5.2                            
 [58] ape_5.8-1                              
 [59] R.oo_1.27.1                            
 [60] glue_1.8.0                             
 [61] restfulr_0.0.16                        
 [62] nlme_3.1-168                           
 [63] GOSemSim_2.34.0                        
 [64] grid_4.5.2                             
 [65] reshape2_1.4.5                         
 [66] fgsea_1.34.2                           
 [67] gtable_0.3.6                           
 [68] tzdb_0.5.0                             
 [69] R.methodsS3_1.8.2                      
 [70] data.table_1.17.8                      
 [71] hms_1.1.4                              
 [72] XVector_0.48.0                         
 [73] ggrepel_0.9.6                          
 [74] pillar_1.11.1                          
 [75] babelgene_22.9                         
 [76] yulab.utils_0.2.1                      
 [77] vroom_1.6.6                            
 [78] splines_4.5.2                          
 [79] treeio_1.32.0                          
 [80] lattice_0.22-7                         
 [81] rtracklayer_1.68.0                     
 [82] bit_4.6.0                              
 [83] tidyselect_1.2.1                       
 [84] GO.db_3.21.0                           
 [85] Biostrings_2.76.0                      
 [86] knitr_1.50                             
 [87] SummarizedExperiment_1.38.1            
 [88] xfun_0.54                              
 [89] matrixStats_1.5.0                      
 [90] stringi_1.8.7                          
 [91] UCSC.utils_1.4.0                       
 [92] lazyeval_0.2.2                         
 [93] ggfun_0.2.0                            
 [94] yaml_2.3.10                            
 [95] boot_1.3-32                            
 [96] evaluate_1.0.5                         
 [97] codetools_0.2-20                       
 [98] qvalue_2.40.0                          
 [99] ggplotify_0.1.3                        
[100] cli_3.6.5                              
[101] Rcpp_1.1.0                             
[102] png_0.1-8                              
[103] XML_3.99-0.20                          
[104] parallel_4.5.2                         
[105] assertthat_0.2.1                       
[106] blob_1.2.4                             
[107] DOSE_4.2.0                             
[108] bitops_1.0-9                           
[109] tidytree_0.4.6                         
[110] scales_1.4.0                           
[111] crayon_1.5.3                           
[112] rlang_1.1.6                            
[113] cowplot_1.2.0                          
[114] fastmatch_1.1-6                        
[115] KEGGREST_1.48.1                        
```


:::
:::

