---
title: "ITT for Dexamethasone Treated HFD-Fed Mice at the MMPC"
author: "Innocence Harvey, Melanie Schmitt, Nathan Qi and Dave Bridges"
date: "April 5, 2017"
output:
  html_document:
    keep_md: yes
  pdf_document:
    keep_tex: yes
---





This document can be found in /Users/iharvey/Desktop/CushingAcromegalyStudy/scripts/scripts-obesity.  It reads from the file ../../data/raw/mmpc-itt-data.csv and this script was most recently run on Sat Apr 21 10:11:30 2018.



![](figures/itt-lineplot-clamp-1.png)<!-- -->

### ITT Statistics



Based on a mixed linear model testing for effects of a Diet:Treatment interaction, there is a significant interaction between Diet and Treatment during the ITT **(p=0.0180343)**.  The residuals of this model fail to meet the criteria for normality via a Shapiro-Wilk test, so normality cannot be assumed (p=2.4019467&times; 10^-10^).

## Normalized to Fasting Glucose

![](figures/itt-lineplot-normalized-clamp-1.png)<!-- -->


## Fasting Blood Glucose

![](figures/itt-fasting-glucose-clamp-1.png)<!-- -->

### Fasting Glucose Statistics

Analysed these data by 2-way ANOVA with an interaction


Table: 2 Way ANOVA for Fasting Glucose

                  Df      Sum Sq      Mean Sq    F value      Pr(>F)
---------------  ---  ----------  -----------  ---------  ----------
Treatment          1    26654.44    26654.442   11.45778   0.0012711
Diet               1   122634.93   122634.925   52.71630   0.0000000
Treatment:Diet     1    41040.14    41040.140   17.64167   0.0000914
Residuals         59   137252.81     2326.319         NA          NA

The residuals from this ANOVA can **not** be assumed to be normally distributed as they fail a Shapiro-Wilk test (p=2.2216492&times; 10^-6^).

## Area Under Curve During ITT

![](figures/itt-auc-barplot-1.png)<!-- -->

### AUC Statistics

Analysed these data by 2-way ANOVA with an interaction


Table: 2 Way ANOVA for Area Under Curve of ITT

                  Df    Sum Sq     Mean Sq     F value      Pr(>F)
---------------  ---  --------  ----------  ----------  ----------
Treatment          1   1665064   1665063.7    7.918326   0.0074825
Diet               1   2246100   2246099.8   10.681483   0.0021939
Treatment:Diet     1   1580386   1580385.9    7.515634   0.0090222
Residuals         41   8621471    210279.8          NA          NA

The residuals from this ANOVA can **not** be assumed to be normally distributed as they fail a Shapiro-Wilk test (p=7.926514&times; 10^-7^).


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
## [1] lme4_1.1-15   Matrix_1.2-12 tidyr_0.8.0   bindrcpp_0.2  dplyr_0.7.4  
## [6] knitr_1.20   
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.15     bindr_0.1        magrittr_1.5     MASS_7.3-47     
##  [5] splines_3.4.3    tidyselect_0.2.3 lattice_0.20-35  R6_2.2.2        
##  [9] rlang_0.2.0      minqa_1.2.4      highr_0.6        stringr_1.3.0   
## [13] tools_3.4.3      grid_3.4.3       nlme_3.1-131     htmltools_0.3.6 
## [17] yaml_2.1.16      assertthat_0.2.0 rprojroot_1.3-2  digest_0.6.15   
## [21] tibble_1.4.2     nloptr_1.0.4     purrr_0.2.4      glue_1.2.0      
## [25] evaluate_0.10.1  rmarkdown_1.8    stringi_1.1.6    compiler_3.4.3  
## [29] pillar_1.1.0     backports_1.1.2  pkgconfig_2.0.1
```
