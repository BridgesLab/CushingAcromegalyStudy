Comparing HTseq_counts with Rsamtool counts
========================================================





```r
library(biomaRt, quietly = TRUE)
```

```
## Warning: package 'biomaRt' was built under R version 3.0.2
```

```r
# get transcript info matching transcript id to external (HNGC) id
ensembl <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
transcriptInfo_noExon <- getBM(attributes = c("ensembl_transcript_id", "external_gene_id", 
    "strand", "chromosome_name", "ensembl_gene_id", "transcript_start", "transcript_end"), 
    values = rownames(filtered_counts), mart = ensembl)
annotated_counts_noExon <- merge(transcriptInfo_noExon, filtered_counts, by.x = "ensembl_transcript_id", 
    by.y = "row.names")
annotated_deseq_results <- merge(transcriptInfo_noExon, deseq_results, by.x = "ensembl_transcript_id", 
    by.y = "id")
htseq_merge_filtered_counts <- merge(annotated_counts_noExon, htseq_counts, 
    by.x = "ensembl_gene_id", by.y = "Genes")
```



```r
# rsamtools counts - htseq counts
diff <- abs(htseq_merge_filtered_counts[, 8:31] - htseq_merge_filtered_counts[, 
    32:55])  #Rsamtools counts - htseq counts
# calculate relative difference
rel_diff <- diff/htseq_merge_filtered_counts[, 8:31]  #divide by the Rsamtools counts
rel_diff$average <- rowMeans(rel_diff)
rownames(rel_diff) <- htseq_merge_filtered_counts$ensembl_gene_id
```



```r
counts_merge_exp <- merge(rel_diff, annotated_deseq_results, by.x = "row.names", 
    by.y = "ensembl_gene_id")
# counts_merge_exp.subset <- counts_merge_exp[counts_merge_exp$baseMeanB <
# 6000,]
pdf("figure/HtSeq_Rsamtools counts relative difference.pdf")
plot(counts_merge_exp$baseMeanB, counts_merge_exp$average, main = "Htseq and Rsamtools Relative Difference vs Avg Exp ", 
    xlab = "Acromegaly Avg Expression", ylab = "Avg Relative Difference", xlim = range(0:2e+05), 
    ylim = range(0:3), pch = 19)
dev.off()
```

```
## pdf 
##   2
```

Session Information
---------------------


```r
sessionInfo()
```

```
## R version 3.0.1 (2013-05-16)
## Platform: x86_64-apple-darwin10.8.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] biomaRt_2.18.0 knitr_1.5     
## 
## loaded via a namespace (and not attached):
## [1] evaluate_0.5.1 formatR_0.10   RCurl_1.95-4.1 stringr_0.6.2 
## [5] tools_3.0.1    XML_3.95-0.2
```

