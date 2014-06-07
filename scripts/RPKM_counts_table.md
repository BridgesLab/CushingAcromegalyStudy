Title making the RPKM table
========================================================



Making the RPKM Table
The counts table was the regularized transformation from DESeq2 using **deseq_analysis_outlier_of_htseq.Rmd**.  It already excluded the outlier sample, which was patient **29**.


```
## Error: undefined columns selected
```

```
## Error: object 'filtered.counts.acro' not found
```

```
## Error: object 'filtered.counts.acro' not found
```

```
## Error: object 'filtered.counts.acro' not found
```

```
## Error: object 'filtered.counts.acro' not found
```

```
## Error: object 'rpm.table' not found
```



```r
# calculate length for each gene
library(GenomicFeatures)
```

```
## Warning: package 'GenomicFeatures' was built under R version 3.0.3
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
# save(txdb,file='txdb.RData') then collect the exons per gene id
exons.list.per.gene <- exonsBy(txdb, by = "gene")
# then for each gene, reduce all the exons to a set of non overlapping
# exons, calculate their lengths (widths) and sum then
exonic.gene.sizes <- lapply(exons.list.per.gene, function(x) {
    sum(width(reduce(x)))
})
gene_lengths <- unlist(exonic.gene.sizes)
comvals <- intersect(names(gene_lengths), rownames(filtered.counts.cushing))

counts.rpkm <- sweep(rpm.table[comvals, ], 1, unlist(gene_lengths[comvals]), 
    "/")
```

```
## Error: object 'rpm.table' not found
```

```r
counts.rpkm.cushing <- sweep(rpm.table.cushing[comvals, ], 1, unlist(gene_lengths[comvals]), 
    "/")

counts.rpkm$Mean.Con <- rowMeans(counts.rpkm[, 1:11])
```

```
## Error: object 'counts.rpkm' not found
```

```r
counts.rpkm$Mean.Acro <- rowMeans(counts.rpkm[, 12:18])
```

```
## Error: object 'counts.rpkm' not found
```

```r

# write.csv(counts.rpkm,
# file='../data/processed/RPKM_counts_Acromegaly_GRCh37.74.csv')
# write.csv(counts.rpkm.cushing,
# file='../data/processed/RPKM_counts_Cushing_GRCh37.74.csv')

# write.csv(counts.rpkm,
# file='../data/processed/RPKM_VSD_Acromegaly_GRCh37.74.csv')
write.csv(counts.rpkm.cushing, file = "../data/processed/RPKM_VSD_counts_table_Cushing.csv")
```



```r
library(reshape2)
gene.lengths.long <- melt(gene_lengths, v.names = "Length")
colnames(gene.lengths.long) <- "Gene.Length"
# remove the last 5 rows
mean.counts <- filtered.counts.acro[1:63675, ]
```

```
## Error: object 'filtered.counts.acro' not found
```

```r
rpm.table.test <- rpm.table
```

```
## Error: object 'rpm.table' not found
```

```r
rpm.table.test$Mean.Con <- rowMeans(rpm.table[, 1:11])
```

```
## Error: object 'rpm.table' not found
```

```r
rpm.table.test$Mean.Acro <- rowMeans(rpm.table[, 12:18])
```

```
## Error: object 'rpm.table' not found
```

```r
rpm.table.test <- rpm.table.test[1:63675, ]
```

```
## Error: object 'rpm.table.test' not found
```

```r

master <- merge(rpm.table.test, gene.lengths.long, by.x = "row.names", by.y = "row.names")
```

```
## Error: error in evaluating the argument 'x' in selecting a method for function 'merge': Error: object 'rpm.table.test' not found
```

```r
master$FC <- master$Mean.Acro/master$Mean.Con
```

```
## Error: object 'master' not found
```

```r
master <- master[order(master$FC, decreasing = T), ]
```

```
## Error: object 'master' not found
```

```r
master.noInf <- master[(master$FC != "Inf"), ]
```

```
## Error: object 'master' not found
```

```r
master.noInf <- master[(master$FC != "NaN"), ]
```

```
## Error: object 'master' not found
```

```r
master.noInf <- master[(master$FC != 0), ]
```

```
## Error: object 'master' not found
```

```r
master.noInf <- master[(master$Mean.Con > 100), ]
```

```
## Error: object 'master' not found
```

```r

library(ggplot2)
ggplot(master.noInf, aes(x = Gene.Length, y = Mean.Con)) + geom_point(shape = 1) + 
    xlim(0, 20000) + ylab("Mean Control Counts") + ylim(0, 5000) + ggtitle("Mean couns vs Gene Length (only genes with counts > 100)")
```

```
## Error: object 'master.noInf' not found
```

```r

ggsave(file = "figure/Mean counts vs Gene Length.pdf")
```

```
## Error: plot should be a ggplot2 plot
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
##  [1] ggplot2_0.9.3.1        reshape2_1.4           GenomicFeatures_1.14.5
##  [4] AnnotationDbi_1.24.0   Biobase_2.22.0         GenomicRanges_1.14.4  
##  [7] XVector_0.2.0          IRanges_1.20.7         BiocGenerics_0.8.0    
## [10] knitr_1.5             
## 
## loaded via a namespace (and not attached):
##  [1] biomaRt_2.18.0     Biostrings_2.30.1  bitops_1.0-6      
##  [4] BSgenome_1.30.0    colorspace_1.2-4   DBI_0.2-7         
##  [7] digest_0.6.4       evaluate_0.5.5     formatR_0.10      
## [10] grid_3.0.2         gtable_0.1.2       MASS_7.3-33       
## [13] munsell_0.4.2      plyr_1.8.1         proto_0.3-10      
## [16] Rcpp_0.11.1        RCurl_1.95-4.1     Rsamtools_1.14.3  
## [19] RSQLite_0.11.4     rtracklayer_1.22.7 scales_0.2.4      
## [22] stats4_3.0.2       stringr_0.6.2      tools_3.0.2       
## [25] XML_3.95-0.2       zlibbioc_1.8.0
```


