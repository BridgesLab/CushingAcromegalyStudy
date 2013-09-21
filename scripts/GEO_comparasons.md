Comparason of Data from our Study with GEO Deposited Data
=============================================================


This analysis removed the lowest 40% expressed transcripts.  This script was most recently run on Sun Sep  1 11:21:13 2013.  





Huo et al Dataset
---------------------

The authors in <a href="http://dx.doi.org/10.1074/jbc.M508492200">Huo (2006)</a> treated 3T3-F442A adipocytes either with nothing or with HG for 0.5, 4 or 48h.  These data are in the dataset GSE2120.  I generated R code using GEO2R comparing the control and growth hormone treated samples at 48h.




### Upregulated Genes

Of the 158 significantly upregulated genes on the chip, 56 had identifiable human homologs, of which there were 75 probes.  These genes were on average **upregulated** to 1.313 of their original control levels.  The p-value that these genes are upregulated is 0.0013.  Of these 75 mouse genes that had probes, 43 were upregulated.  Specifically, these genes were GGCT, ABHD5, ESR1, ORC2, PPP3R1, GAB1, MYEF2, IGFBP3, TCF7L2, SIDT2, WDR92, SERPINI1, CYB5A, MAPRE2, PTGER3, IGF1, GPM6B, CAPN6, AK4, UGP2, SOCS2, CCNG1, PLD1, CISH, GNAI1, PLAGL1, FMO1, STAT4, BMP5, SCP2, EPHX2

### Downregulated Genes

Of the 44 significantly downregulated genes, 13 had identifiable human homologs on that array chip, of which there were 15 probes.  These genes were on average **downregulated** to 0.9006 of their original control levels.  The p-value that these genes are downregulated is 0.1945.  Of these 15 mouse genes that had probes, 6 were downregulated.  Specifically, these genes were TUBA4A, RDH5, CDKN2B, FOS, GAS6, RASA3.

### Enrichment Testing
We found 202 significantly different genes in the acromegaly study.  Our re-analysis of the growth hormone study found 560 differentially expressed genes.  That corresponds to 6.0929% of the genes are different.  Out of those genes, 419 map to human homologs.  Out of the transcripts mapped to those genes, 86 out of 2372 (or 3.6256%)` were significantly different in the acromegaly data, so there was no enrichment.

Done the other way, we found 202 significantly different acromegaly genes out of a total of 20848 genes tested (or 0.9689%).  Out of these 202 genes, 69 have mouse homologs, and 88 probes in this dataset.  From these probes, 18 were significant (or 19.2247%).  Therefore the genes from the acromegaly dataset are enriched in the growth hormone treated dataset (p=1.95 &times; 10<sup>-7</sup>).  The genes which were significant in both datasets were Cish, Pld1, Fmo1, Phldb2, Igsf10, Ccng1, Wisp2, Ggct, Igfbp3, Igf1, Scd2, Scp2, Ptger3, Capn6, Socs2

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

