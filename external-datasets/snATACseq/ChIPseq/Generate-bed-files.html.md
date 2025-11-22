---
title: "Generation of UCSC formatted BigBed files"
author: "Dave Bridges"
date: "2025-11-22"
editor: source
format: 
  html:
    toc: true
    toc-location: right
    keep-md: true
    code-fold: true
    code-summary: "Show the code"
    fig-path: "figures/"
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

Convert into excel files into BED files

## Experimental Details


## Raw Data

Data from Ying *et al.,* 2010 at http://dx.doi.org/10.1371/journal.pone.0015188


::: {.cell}

```{.r .cell-code}
library(readxl) #loads the readr package
filename <- "pone.0015188.s001.xls" #input file(s)

exp.data <- read_excel(filename, skip=1)
#BiocManager::install("rtracklayer")
library(rtracklayer)
bed <- exp.data |>
  mutate(chrom= `chromosome number`,
         chromsStart = startpeak - 1,  # convert to 0-based
         chromEnd   = endpeak,
         name = `user defined string`,
         score = 0,
         strand = '.') |>
  select(chrom, chromsStart, chromEnd, name, score, strand) |>
  na.omit()

bed.filename <- "pone.0015188.s001.bed"
write_tsv(bed, bed.filename, col_names = FALSE)
```
:::


Had to convert this from mm9 to mm10 by liftover at https://genome.ucsc.edu/cgi-bin/hgLiftOver.  

Then converted to bigbed with this command


::: {.cell}

```{.r .cell-code}
read_tsv('../GSE236575/results/motif_analysis/bed_files/HFD_specific_chr.bed', 
         col_names = c('chrom','chromStart','chromEnd')) |>
  mutate(name = paste0('HFD_specific_', row_number()),
         score = 0,
         strand = '.') |>
  write_tsv('GSE236575_HFD_specific.bed', col_names = FALSE)

read_tsv('../GSE236575/results/motif_analysis/bed_files/CHD_specific_chr.bed', 
         col_names = c('chrom','chromStart','chromEnd')) |>
  mutate(name = paste0('NCD_specific_', row_number()),
         score = 0,
         strand = '.') |>
  write_tsv('GSE236575_CHD_specific.bed', col_names = FALSE)

read_tsv('../GSE236575/results/motif_analysis/bed_files/shared_chr.bed', 
         col_names = c('chrom','chromStart','chromEnd')) |>
  mutate(name = paste0('shared_', row_number()),
         score = 0,
         strand = '.') |>
  write_tsv('GSE236575_shared.bed', col_names = FALSE)
```
:::


## Create BigBed files

` bedToBigBed -type=bed6 -sort pone.0015188.s001_mm10.bed mm10.chrom.sizes pone.0015188.s001.bb`
`bedToBigBed -type=bed6 -sort GSE236575_shared.bed mm10.chrom.sizes GSE236575_shared.bb`
`bedToBigBed -type=bed6 -sort GSE236575_CHD_specific.bed mm10.chrom.sizes GSE236575_CHD_specific.bb`
`bedToBigBed -type=bed6 -sort GSE236575_HFD_specific.bed mm10.chrom.sizes GSE236575_HFD_specific.bb`

## Peak Overlap


::: {.cell}

```{.r .cell-code}
library(rtracklayer)
library(GenomicRanges)
library(dplyr)

# 1. Read your two BED files (automatically handles .bed, .bed.gz, etc.)
hfd.atac_peaks  <- import("GSE236575_HFD_specific.bed")   # your ATAC peaks
ncd.atac_peaks  <- import("GSE236575_CHD_specific.bed")   # your ATAC peaks
chip_peaks  <- import("pone.0015188.s001_mm10.bed")

# 2. Make sure they are proper GRanges with names (optional but very useful)
# If your BED files have a 4th column with peak IDs, they will be used as names
# Otherwise we give them unique IDs:
if (is.null(names(hfd.atac_peaks)))  names(hfd.atac_peaks) <- paste0("ATAC_", 1:length(hfd.atac_peaks))
if (is.null(names(hfd.atac_peaks)))  names(ncd.atac_peaks) <- paste0("ATAC_", 1:length(ncd.atac_peaks))
if (is.null(names(chip_peaks)))  names(chip_peaks) <- paste0("ChIP_", 1:length(chip_peaks))

# 3. Find overlaps
# hits = which ChIP-seq peaks overlap at least one ATAC-seq peak
hfd.hits <- findOverlaps(chip_peaks, hfd.atac_peaks, type = "any", select = "all")
ncd.hits <- findOverlaps(chip_peaks, ncd.atac_peaks, type = "any", select = "all")

# 4. Extract the overlapping ChIP-seq peaks
hfd.chip_peaks_that_overlap_ATAC <- chip_peaks[queryHits(hfd.hits)]
ncd.chip_peaks_that_overlap_ATAC <- chip_peaks[queryHits(ncd.hits)]

# 5. How many ChIP-seq peaks overlap ATAC?
cat(sprintf("%d out of %d ChIP-seq peaks (%.1f%%) overlap at least one ATAC-seq peak from HFD\n",
      length(unique(queryHits(hfd.hits))),
      length(chip_peaks),
      100 * length(unique(queryHits(hfd.hits))) / length(chip_peaks)))
```

::: {.cell-output .cell-output-stdout}

```
141 out of 8845 ChIP-seq peaks (1.6%) overlap at least one ATAC-seq peak from HFD
```


:::

```{.r .cell-code}
cat(sprintf("%d out of %d ChIP-seq peaks (%.1f%%) overlap at least one ATAC-seq peak from NCD\n",
      length(unique(queryHits(ncd.hits))),
      length(chip_peaks),
      100 * length(unique(queryHits(ncd.hits))) / length(chip_peaks)))
```

::: {.cell-output .cell-output-stdout}

```
257 out of 8845 ChIP-seq peaks (2.9%) overlap at least one ATAC-seq peak from NCD
```


:::
:::


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
 [1] rtracklayer_1.68.0   GenomicRanges_1.60.0 GenomeInfoDb_1.44.3 
 [4] IRanges_2.42.0       S4Vectors_0.46.0     BiocGenerics_0.54.1 
 [7] generics_0.1.4       readxl_1.4.5         lubridate_1.9.4     
[10] forcats_1.0.1        stringr_1.6.0        dplyr_1.1.4         
[13] purrr_1.2.0          readr_2.1.6          tidyr_1.3.1         
[16] tibble_3.3.0         ggplot2_4.0.1        tidyverse_2.0.0     

loaded via a namespace (and not attached):
 [1] SummarizedExperiment_1.38.1 gtable_0.3.6               
 [3] rjson_0.2.23                xfun_0.54                  
 [5] htmlwidgets_1.6.4           lattice_0.22-7             
 [7] Biobase_2.68.0              tzdb_0.5.0                 
 [9] vctrs_0.6.5                 tools_4.5.2                
[11] bitops_1.0-9                curl_7.0.0                 
[13] parallel_4.5.2              pkgconfig_2.0.3            
[15] Matrix_1.7-4                RColorBrewer_1.1-3         
[17] S7_0.2.1                    lifecycle_1.0.4            
[19] GenomeInfoDbData_1.2.14     compiler_4.5.2             
[21] farver_2.1.2                Rsamtools_2.24.1           
[23] Biostrings_2.76.0           codetools_0.2-20           
[25] htmltools_0.5.8.1           RCurl_1.98-1.17            
[27] yaml_2.3.10                 pillar_1.11.1              
[29] crayon_1.5.3                BiocParallel_1.42.2        
[31] DelayedArray_0.34.1         abind_1.4-8                
[33] tidyselect_1.2.1            digest_0.6.38              
[35] stringi_1.8.7               restfulr_0.0.16            
[37] fastmap_1.2.0               grid_4.5.2                 
[39] SparseArray_1.8.1           cli_3.6.5                  
[41] magrittr_2.0.4              S4Arrays_1.8.1             
[43] XML_3.99-0.20               withr_3.0.2                
[45] scales_1.4.0                UCSC.utils_1.4.0           
[47] bit64_4.6.0-1               timechange_0.3.0           
[49] rmarkdown_2.30              XVector_0.48.0             
[51] httr_1.4.7                  matrixStats_1.5.0          
[53] bit_4.6.0                   cellranger_1.1.0           
[55] hms_1.1.4                   evaluate_1.0.5             
[57] knitr_1.50                  BiocIO_1.18.0              
[59] rlang_1.1.6                 glue_1.8.0                 
[61] vroom_1.6.6                 rstudioapi_0.17.1          
[63] jsonlite_2.0.0              R6_2.6.1                   
[65] MatrixGenerics_1.20.0       GenomicAlignments_1.44.0   
```


:::
:::

