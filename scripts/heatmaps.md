Analysis of Data for Acromegaly Patients by Heatmaps
=============================================================

Statistics
----------


```
## Loading required package: knitcitations Loading required package: bibtex
## 
## Attaching package: 'knitcitations'
## 
## The following object is masked from 'package:utils':
## 
## cite
```

This file was most recently processed on ``Wed Sep  4 11:58:34 2013``.  This uses the genes which were subsetted (only the highest 40\%).  Also, this uses the DESeq normalized data.

Data Clustering
----------------
The following is a cluster analysis of the scaled transcript counts.  This was done with bootstrap resampling of the normalized, scaled transcript counts using the **pvclust** package(<a href="http://CRAN.R-project.org/package=pvclust">Suzuki & Shimodaira, 2011</a>)). 


```
## Warning: did not converge in 10 iterations Warning: did not converge in 10
## iterations Warning: did not converge in 10 iterations
```

![plot of chunk clustering](figure/clustering1.png) 

```
## Bootstrap (r = 0.5)... Done.
## Bootstrap (r = 0.6)... Done.
## Bootstrap (r = 0.7)... Done.
## Bootstrap (r = 0.8)... Done.
## Bootstrap (r = 0.9)... Done.
## Bootstrap (r = 1.0)... Done.
## Bootstrap (r = 1.1)... Done.
## Bootstrap (r = 1.2)... Done.
## Bootstrap (r = 1.3)... Done.
## Bootstrap (r = 1.4)... Done.
```

![plot of chunk clustering](figure/clustering2.png) 



Differentially Expressed Genes
----------------------------------

To test the grouping of differentially expressed transcripts, we only examined genes with significantly different transcripts based on DESeq analysis.


```
## gdata: read.xls support for 'XLS' (Excel 97-2004) files ENABLED.
## 
## gdata: read.xls support for 'XLSX' (Excel 2007+) files ENABLED.
## 
## Attaching package: 'gdata'
## 
## The following object is masked from 'package:stats':
## 
## nobs
## 
## The following object is masked from 'package:utils':
## 
## object.size
## 
## KernSmooth 2.23 loaded Copyright M. P. Wand 1997-2009
## 
## Attaching package: 'gplots'
## 
## The following object is masked from 'package:stats':
## 
## lowess
```

![plot of chunk de-heatmap](figure/de-heatmap1.png) ![plot of chunk de-heatmap](figure/de-heatmap2.png) 

```
## pdf 
##   2
```


References
-----------

- Ryota Suzuki, Hidetoshi Shimodaira,   (2011) pvclust: Hierarchical Clustering with P-Values via Multiscale Bootstrap
Resampling.  [http://CRAN.R-project.org/package=pvclust](http://CRAN.R-project.org/package=pvclust)


Session Information
-------------------

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
## [1] grid      stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
##  [1] RColorBrewer_1.0-5  gplots_2.11.3       MASS_7.3-28        
##  [4] KernSmooth_2.23-10  caTools_1.14        gdata_2.13.2       
##  [7] gtools_3.0.0        pvclust_1.2-2       knitcitations_0.5-0
## [10] bibtex_0.3-6        knitr_1.4          
## 
## loaded via a namespace (and not attached):
##  [1] bitops_1.0-5   digest_0.6.3   evaluate_0.4.7 formatR_0.9   
##  [5] httr_0.2       RCurl_1.95-4.1 stringr_0.6.2  tools_3.0.1   
##  [9] XML_3.95-0.2   xtable_1.7-1
```

