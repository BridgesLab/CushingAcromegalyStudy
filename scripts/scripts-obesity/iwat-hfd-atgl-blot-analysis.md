---
title: "Combined Analysis of HFD/NCD Dexamethasone WAT ATGL Levels"
author: "Innocence Harvey and Dave Bridges"
date: "February 11, 2016"
output:
  html_document:
    toc: yes
    keep_md: yes
    number_sections: no
  pdf_document:
    highlight: tango
    keep_tex: yes
    number_sections: no
    toc: yes
---





Table: Blot summary values

Diet               Treatment        mean      se   length   shapiro.p
-----------------  --------------  -----  ------  -------  ----------
Normal Chow Diet   Water            1.00   0.148        6       0.583
Normal Chow Diet   Dexamethasone    1.54   0.269        6       0.380
High Fat Diet      Water            1.10   0.166        6       0.990
High Fat Diet      Dexamethasone    2.63   0.317        5       0.290


This script uses the files in ../../data/raw/HFD vs NCD ATGL Blot Quantification.csv. These data are located in /Users/iharvey/Desktop/CushingAcromegalyStudy/scripts/scripts-obesity and this script was most recently run on Sat Apr 21 10:36:40 2018.

![](figures/atgl-wat-barplot-1.png)<!-- -->

Blots were normalized to total protein (Revert) staining.  We observed a 1.544 fold increase in NCD animals due to dexamethasone and a 2.396 fold increase in HFD animals.

# Statistics



From a two-way ANOVA with an interaction, the interaction term was significant **p=0.043**:


Table: ANOVA for WAT ATGL Levels

                  Df   Sum Sq   Mean Sq   F value   Pr(>F)
---------------  ---  -------  --------  --------  -------
Diet               1     1.57     1.569      5.27    0.033
Treatment          1     5.90     5.899     19.82    0.000
Diet:Treatment     1     1.40     1.397      4.69    0.043
Residuals         19     5.66     0.298        NA       NA

Tukey's tests (pairwise  comparasons are):


Table: Tukey's HSD tests for iWAT ATGL Levels

                                                               diff      lwr     upr   p adj
-----------------------------------------------------------  ------  -------  ------  ------
High Fat Diet:Water-Normal Chow Diet:Water                    0.098   -0.787   0.984   0.989
Normal Chow Diet:Dexamethasone-Normal Chow Diet:Water         0.544   -0.342   1.430   0.338
High Fat Diet:Dexamethasone-Normal Chow Diet:Water            1.631    0.702   2.560   0.000
Normal Chow Diet:Dexamethasone-High Fat Diet:Water            0.446   -0.440   1.332   0.505
High Fat Diet:Dexamethasone-High Fat Diet:Water               1.533    0.604   2.462   0.001
High Fat Diet:Dexamethasone-Normal Chow Diet:Dexamethasone    1.087    0.158   2.016   0.018

# Session Information


```
## R version 3.4.3 (2017-11-30)
## Platform: x86_64-apple-darwin15.6.0 (64-bit)
## Running under: OS X El Capitan 10.11.6
## 
## Matrix products: default
## BLAS: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRblas.0.dylib
## LAPACK: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRlapack.dylib
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] bindrcpp_0.2  tidyr_0.8.0   dplyr_0.7.4   forcats_0.3.0 readr_1.1.1  
## [6] knitr_1.20   
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.15     bindr_0.1        magrittr_1.5     hms_0.4.1       
##  [5] tidyselect_0.2.3 R6_2.2.2         rlang_0.2.0      highr_0.6       
##  [9] stringr_1.3.0    tools_3.4.3      htmltools_0.3.6  yaml_2.1.16     
## [13] rprojroot_1.3-2  digest_0.6.15    assertthat_0.2.0 tibble_1.4.2    
## [17] purrr_0.2.4      glue_1.2.0       evaluate_0.10.1  rmarkdown_1.8   
## [21] stringi_1.1.6    compiler_3.4.3   pillar_1.1.0     backports_1.1.2 
## [25] pkgconfig_2.0.1
```
