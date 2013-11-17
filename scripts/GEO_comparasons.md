Comparason of Data from our Study with GEO Deposited Data
=============================================================


This script was most recently run on Sun Nov 17 11:36:28 2013.  





Huo et al Dataset
---------------------

The authors in <a href="http://dx.doi.org/10.1074/jbc.M508492200">Huo (2006)</a> treated 3T3-F442A adipocytes either with nothing or with HG for 0.5, 4 or 48h.  These data are in the dataset GSE2120.  I generated R code using GEO2R comparing the control and growth hormone treated samples at 48h.




### Upregulated Genes

Of the 78 significantly upregulated genes on the chip, 24 had identifiable human homologs, of which there were 38 probes.  These genes were on average **upregulated** to 1.3119 of their original control levels.  The p-value that these genes are upregulated is 0.0404.  Of these 38 mouse genes that had probes, 21 were upregulated.  Specifically, these genes were CCNE1, IGFBP3, CAPN6, ADRB3, PTGER3, TCF7L2, STAT4, FMO1, BMP5, SCP2, SERPINI1, IGF1, ABHD5

### Downregulated Genes

Of the 25 significantly downregulated genes, 10 had identifiable human homologs on that array chip, of which there were 12 probes.  These genes were on average **downregulated** to 0.7769 of their original control levels.  The p-value that these genes are downregulated is 0.048.  Of these 12 mouse genes that had probes, 3 were downregulated.  Specifically, these genes were CDKN2B, RASA3, TUBA4A.

### Enrichment Testing
We found 103 significantly different genes in the acromegaly study.  Our re-analysis of the growth hormone study found 560 differentially expressed genes.  That corresponds to 6.0929% of the genes are different.  Out of those genes, 432 map to human homologs.  Out of the transcripts mapped to those genes, 9 out of 427 (or 2.1077%)` were significantly different in the acromegaly data, so there was no enrichment.

Done the other way, we found 103 significantly different acromegaly genes out of a total of 53656 genes tested (or 0.192%).  Out of these 103 genes, 34 have mouse homologs, and 48 probes in this dataset.  From these probes, 12 were significant (or 23.4898%).  Therefore the genes from the acromegaly dataset are enriched in the growth hormone treated dataset (p=2.161 &times; 10<sup>-6</sup>).  The genes which were significant in both datasets were Fmo1, Igsf10, Igfbp3, Cxcl1, Igf1, Scd2, Scp2, Ptger3, Capn6

References
-----------

```r
bibliography()
```

```
## 
## - J. S. Huo,   (2006) Profiles of Growth Hormone (gh)-Regulated Genes Reveal Time-Dependent Responses And Identify A Mechanism For Regulation of Activating Transcription Factor 3 by gh.  *Journal of Biological Chemistry*  **281**  4132-4141  [10.1074/jbc.M508492200](http://dx.doi.org/10.1074/jbc.M508492200)
```


Session Information
-------------------

For the R session, the package versions were:

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
## [1] biomaRt_2.18.0      limma_3.18.3        GEOquery_2.28.0    
## [4] Biobase_2.22.0      BiocGenerics_0.8.0  knitcitations_0.5-0
## [7] bibtex_0.3-6        devtools_1.3        knitr_1.5          
## 
## loaded via a namespace (and not attached):
##  [1] digest_0.6.3   evaluate_0.5.1 formatR_0.10   httr_0.2      
##  [5] memoise_0.1    RCurl_1.95-4.1 stringr_0.6.2  tools_3.0.2   
##  [9] whisker_0.3-2  XML_3.95-0.2   xtable_1.7-1
```

