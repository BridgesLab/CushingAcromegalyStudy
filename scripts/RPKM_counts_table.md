Title making the RPKM table
========================================================



Making the RPKM Table
The counts table was the regularized transformation from DESeq2 using **deseq_analysis_outlier_of_htseq.Rmd**.  It already excluded the outlier sample, which was patient **29**.





```r

# calculate length for each gene
library(GenomicFeatures)
```

```
## Loading required package: BiocGenerics
## Loading required package: parallel
## 
## Attaching package: 'BiocGenerics'
## 
## The following objects are masked from 'package:parallel':
## 
##     clusterApply, clusterApplyLB, clusterCall, clusterEvalQ,
##     clusterExport, clusterMap, parApply, parCapply, parLapply,
##     parLapplyLB, parRapply, parSapply, parSapplyLB
## 
## The following object is masked from 'package:stats':
## 
##     xtabs
## 
## The following objects are masked from 'package:base':
## 
##     anyDuplicated, append, as.data.frame, as.vector, cbind,
##     colnames, duplicated, eval, evalq, Filter, Find, get,
##     intersect, is.unsorted, lapply, Map, mapply, match, mget,
##     order, paste, pmax, pmax.int, pmin, pmin.int, Position, rank,
##     rbind, Reduce, rep.int, rownames, sapply, setdiff, sort,
##     table, tapply, union, unique, unlist
## 
## Loading required package: IRanges
## Loading required package: GenomicRanges
## Loading required package: XVector
## Loading required package: AnnotationDbi
## Loading required package: Biobase
## Welcome to Bioconductor
## 
##     Vignettes contain introductory material; view with
##     'browseVignettes()'. To cite Bioconductor, see
##     'citation("Biobase")', and for packages 'citation("pkgname")'.
```

```r
txdb <- makeTranscriptDbFromGFF("../data/raw/Homo_sapiens.GRCh37.74.gtf", format = "gtf")
```

```
## extracting transcript information
## Estimating transcript ranges.
## Extracting gene IDs
## Processing splicing information for gtf file.
## Deducing exon rank from relative coordinates provided
```

```
## Warning: Infering Exon Rankings.  If this is not what you expected, then
## please be sure that you have provided a valid attribute for
## exonRankAttributeName
```

```
## Prepare the 'metadata' data frame ... metadata: OK
## Now generating chrominfo from available sequence names. No chromosome length information is available.
```

```r
save(txdb, file = "txdb.RData")
# then collect the exons per gene id
exons.list.per.gene <- exonsBy(txdb, by = "gene")
# then for each gene, reduce all the exons to a set of non overlapping
# exons, calculate their lengths (widths) and sum then
exonic.gene.sizes <- lapply(exons.list.per.gene, function(x) {
    sum(width(reduce(x)))
})
gene_lengths <- unlist(exonic.gene.sizes)
comvals <- intersect(names(gene_lengths), rownames(rpm.table))

counts.rpkm <- sweep(rpm.table[comvals, ], 1, unlist(gene_lengths[comvals]), 
    "/")
write.csv(counts.rpkm, file = processed_filename)
```



Session Information
---------------------


```r
sessionInfo()
```

```
## R version 3.0.2 (2013-09-25)
## Platform: x86_64-apple-darwin10.8.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] parallel  stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
## [1] GenomicFeatures_1.14.3 AnnotationDbi_1.24.0   Biobase_2.22.0        
## [4] GenomicRanges_1.14.4   XVector_0.2.0          IRanges_1.20.6        
## [7] BiocGenerics_0.8.0     knitr_1.5             
## 
## loaded via a namespace (and not attached):
##  [1] biomaRt_2.18.0     Biostrings_2.30.1  bitops_1.0-6      
##  [4] BSgenome_1.30.0    DBI_0.2-7          evaluate_0.5.1    
##  [7] formatR_0.10       RCurl_1.95-4.1     Rsamtools_1.14.3  
## [10] RSQLite_0.11.4     rtracklayer_1.22.4 stats4_3.0.2      
## [13] stringr_0.6.2      tools_3.0.2        XML_3.95-0.2      
## [16] zlibbioc_1.8.0
```


