Summary of Age-Corrected Effects
========================================================



This analysis uses as an input the age-adjusted analysis, found in ../data/processed/Annotated_Results_GRCh37.74_Acromegaly_age.csv.  This script was most recently run on Tue Sep 23 14:31:17 2014.  

Number of Significantly Different Genes
----------------------------------------

After adjusting for age there were 75 significantly different genes.  There were also 87 significantly different genes in the 40-60 year old cohort and 4 genes in the 60+ cohort.  All together this includes 134.  The overlap between these genes is shown below


```
## Warning: package 'RBGL' was built under R version 3.1.1
## Warning: package 'xtable' was built under R version 3.1.1
```

![plot of chunk age-adjusted-venn](figure/age-adjusted-venn.pdf) 

Session Information
-------------------

```r
sessionInfo()
```

```
## R version 3.1.0 (2014-04-10)
## Platform: x86_64-apple-darwin13.1.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] grid      stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
## [1] Vennerable_3.0     xtable_1.7-4       gtools_3.4.1      
## [4] reshape_0.8.5      RColorBrewer_1.0-5 lattice_0.20-29   
## [7] RBGL_1.40.1        graph_1.42.0       knitr_1.6         
## 
## loaded via a namespace (and not attached):
## [1] BiocGenerics_0.10.0 evaluate_0.5.5      formatR_1.0        
## [4] parallel_3.1.0      plyr_1.8.1          Rcpp_0.11.2        
## [7] stats4_3.1.0        stringr_0.6.2       tools_3.1.0
```

