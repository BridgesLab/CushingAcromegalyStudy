Counts Table Filtering
========================================================

Rather than looking at all transcripts, since we are ignoring all but the most abundant one,  we should filter the counts table to only include the highest expressing gene product.  This should be done prior to running DESeq.




This starts with the file **../data/raw/transcript_counts_table.csv** and then ends up with **../data/processed/filtered_transcript_counts_table.csv**.  We first have to annotate the transcripts with the correct gene name.





```r
# this script is modified from a stackoverflow answer
# http://stackoverflow.com/a/10094437/145318
maxRows <- by(annotated_raw_counts, annotated_raw_counts$external_gene_id, function(X) X[which.max(X$Sum), 
    ])
filtered_raw_counts <- do.call("rbind", maxRows)
# restructured data to remove extra rows.
filtered_raw_counts_data <- filtered_raw_counts[3:26]
rownames(filtered_raw_counts_data) <- filtered_raw_counts$ensembl_transcript_id
write.csv(filtered_raw_counts_data, file = processed_filename)
```

We start with 205537 transcripts and finishes with 53656 so we are reducing the number of genes being assayed by 26.1053%.

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
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] biomaRt_2.18.0 knitr_1.5     
## 
## loaded via a namespace (and not attached):
## [1] evaluate_0.5.1 formatR_0.9    RCurl_1.95-4.1 stringr_0.6.2 
## [5] tools_3.0.2    XML_3.95-0.2
```

