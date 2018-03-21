---
title: "ITT for Dexamethasone Treated HFD-Fed Mice"
author: "Innocence Harvey, Erin Stephenson and Dave Bridges"
date: "February 11, 2015"
output:
  html_document:
    keep_md: true
    fig_caption: true
---





These data were found in the files ../../data/raw/HFD ITT Data.csv and ../../data/raw/NCD ITT Data.csv.  This document can be found in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity.  This scipt was mst recently run on Wed Mar 21 11:16:28 2018.


Table: Summary Statistics for ITT

Treatment       Diet    FG.mean     FG.se     FG.sd   AUC.mean    AUC.se    n
--------------  -----  --------  --------  --------  ---------  --------  ---
Dexamethasone   NCD      118.25    5.5475    19.217     613.75    31.813   12
Dexamethasone   HFD      318.25   35.3986   122.624    2768.83   335.628   12
Water           NCD      143.58    7.3283    25.386     608.62    53.526   12
Water           HFD      177.42   12.3622    42.824     584.14    56.221   12

![](figures/itt-lineplot-1.png)<!-- -->

### ITT Statistics



Based on a mixed linear model testing for effects of a Diet:Treatment interaction, there is a significant interaction between Diet and Treatment during the ITT **(p=1.87576&times; 10^-8^)**.  The residuals of this model fail to meet the criteria for normality via a Shapiro-Wilk test, so normality cannot be assumed (p=1.66328&times; 10^-15^).

## Normalized to Fasting Glucose

![](figures/itt-lineplot-normalized-1.png)<!-- -->


## Fasting Blood Glucose

![](figures/itt-fasting-glucose-1.png)<!-- -->

While HFD animals had a 23.56355% increase in fasting glucose when compared to NCD animals, in the presence of dexamethasone, HFD-fed animals had a 121.64829% increase in fasting glucose relative to NCD controls not treated with dexamethasone.

In the chow condition, dexamethasone caused a 17.64364% decrease in fasting glucose.

### Fasting Glucose Statistics

Analysed these data by 2-way ANOVA with an interaction


Table: 2 Way ANOVA for Fasting Glucose

                  Df   Sum Sq    Mean Sq   F value    Pr(>F)
---------------  ---  -------  ---------  --------  --------
Treatment          1    40021    40020.8     8.951   0.00453
Diet               1   164034   164034.1    36.688   0.00000
Treatment:Diet     1    82834    82834.1    18.527   0.00009
Residuals         44   196728     4471.1        NA        NA

The residuals from this ANOVA can **not** be assumed to be normally distributed as they fail a Shapiro-Wilk test (p=0.0013).

#### Fasting Glucose Power Analysis



We estimate an effect size (from NCD/Water to HFD/Dexamethasone) of 174.66667 (or 3.32617 standard deviations).

In order to detect 50% of this effect size (an decrease of 87.33333mg/dL or a Cohen's d of 1.66308) with knockout, we require at least 6.78472 animals.  With eight animals per group, we calculate that we will have a statistical power of 0.87097. Alternately with eight aninmals per group, we can detect effect sizes of at  79.11852 with 80% power.
 
## Area Under Curve During ITT

![](figures/itt-auc-barplot-1.png)<!-- -->

### AUC Statistics

Analysed these data by 2-way ANOVA with an interaction


Table: 2 Way ANOVA for Area Under Curve of ITT

                  Df     Sum Sq    Mean Sq   F value    Pr(>F)
---------------  ---  ---------  ---------  --------  --------
Treatment          1   14700447   14700447    29.549   0.00001
Diet               1   12319220   12319220    24.762   0.00002
Treatment:Diet     1    9976062    9976062    20.052   0.00010
Residuals         31   15422526     497501        NA        NA

The residuals from this ANOVA can **not** be assumed to be normally distributed as they fail a Shapiro-Wilk test (p=0.00012).


# Session Information


```
## R version 3.4.2 (2017-09-28)
## Platform: x86_64-apple-darwin15.6.0 (64-bit)
## Running under: macOS High Sierra 10.13.3
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
## [1] pwr_1.2-1     lme4_1.1-14   Matrix_1.2-12 tidyr_0.7.2   bindrcpp_0.2 
## [6] dplyr_0.7.4   knitr_1.17   
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.14     bindr_0.1        magrittr_1.5     MASS_7.3-47     
##  [5] splines_3.4.2    tidyselect_0.2.3 lattice_0.20-35  R6_2.2.2        
##  [9] rlang_0.1.4      minqa_1.2.4      stringr_1.2.0    highr_0.6       
## [13] tools_3.4.2      grid_3.4.2       nlme_3.1-131     htmltools_0.3.6 
## [17] yaml_2.1.15      assertthat_0.2.0 rprojroot_1.2    digest_0.6.12   
## [21] tibble_1.3.4     nloptr_1.0.4     purrr_0.2.4      glue_1.2.0      
## [25] evaluate_0.10.1  rmarkdown_1.8    stringi_1.1.6    compiler_3.4.2  
## [29] backports_1.1.1  pkgconfig_2.0.1
```
