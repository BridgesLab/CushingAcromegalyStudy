Comparason of Data from our Study with GEO Deposited Data
=============================================================


This analysis removed the lowest 40% expressed transcripts.  This script was most recently run on Sat Sep 21 08:40:31 2013.  





Huo et al Dataset
---------------------

The authors in <a href="http://dx.doi.org/10.1074/jbc.M508492200">Huo (2006)</a> treated 3T3-F442A adipocytes either with nothing or with HG for 0.5, 4 or 48h.  These data are in the dataset GSE2120.  I generated R code using GEO2R comparing the control and growth hormone treated samples at 48h.




### Upregulated Genes

Of the 124 significantly upregulated genes on the chip, 45 had identifiable human homologs, of which there were 62 probes.  These genes were on average **upregulated** to 1.199 of their original control levels.  The p-value that these genes are upregulated is 0.0364.  Of these 62 mouse genes that had probes, 32 were upregulated.  Specifically, these genes were ABHD5, ESR1, ORC2, MYEF2, IGFBP3, TCF7L2, SIDT2, SERPINI1, CYB5A, PTGER3, IGF1, CAPN6, AK4, UGP2, CCNG1, GNAI1, PLAGL1, FMO1, STAT4, BMP5, SCP2, EPHX2

### Downregulated Genes

Of the 33 significantly downregulated genes, 10 had identifiable human homologs on that array chip, of which there were 12 probes.  These genes were on average **downregulated** to 0.9147 of their original control levels.  The p-value that these genes are downregulated is 0.1414.  Of these 12 mouse genes that had probes, 4 were downregulated.  Specifically, these genes were TUBA4A, RDH5, CDKN2B, RASA3.

### Enrichment Testing
We found 157 significantly different genes in the acromegaly study.  Our re-analysis of the growth hormone study found 560 differentially expressed genes.  That corresponds to 6.0929% of the genes are different.  Out of those genes, 432 map to human homologs.  Out of the transcripts mapped to those genes, 62 out of 2394 (or 2.5898%)` were significantly different in the acromegaly data, so there was no enrichment.

Done the other way, we found 157 significantly different acromegaly genes out of a total of 20841 genes tested (or 0.7533%).  Out of these 157 genes, 55 have mouse homologs, and 72 probes in this dataset.  From these probes, 12 were significant (or 15.4384%).  Therefore the genes from the acromegaly dataset are enriched in the growth hormone treated dataset (p=1.6104 &times; 10<sup>-4</sup>).  The genes which were significant in both datasets were Fmo1, Phldb2, Igsf10, Ccng1, Igfbp3, Igf1, Scd2, Scp2, Ptger3, Capn6

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
## R version 3.0.1 (2013-05-16)
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
## [1] biomaRt_2.16.0      limma_3.16.7        GEOquery_2.26.2    
## [4] Biobase_2.20.1      BiocGenerics_0.6.0  knitcitations_0.5-0
## [7] bibtex_0.3-6        devtools_1.3        knitr_1.4          
## 
## loaded via a namespace (and not attached):
##  [1] digest_0.6.3   evaluate_0.4.7 formatR_0.9    httr_0.2      
##  [5] memoise_0.1    RCurl_1.95-4.1 stringr_0.6.2  tools_3.0.1   
##  [9] whisker_0.3-2  XML_3.95-0.2   xtable_1.7-1
```

