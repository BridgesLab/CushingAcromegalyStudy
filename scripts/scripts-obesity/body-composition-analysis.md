---
title: "Combined Analysis of HFD/NCD Dexamethasone Treatment"
author: "Innocence Harvey and Dave Bridges"
date: "April 1, 2015"
output:
  html_document:
    toc: yes
    keep_md: yes
---





This script uses the files in ../../data/raw/Normal Chow Diet Body Composition Data.csv and ../../data/raw/High Fat Diet Body Composition Data.csv.  These data are located in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity and this script was most recently run on Mon Sep 24 10:54:07 2018.  These data were written out in summary format to the file ../../data/processed/Summarized Body Composition Data.csv.

# Body Weights

![](figures/weights-scatterplot-1.png)<!-- -->


# Lean Mass

![](figures/lean-mass-scatterplot-1.png)<!-- -->

# Fat Mass

![](figures/fat-mass-scatterplot-1.png)<!-- -->


# Percent Fat Mass

![](figures/percent-fat-mass-scatterplot-1.png)<!-- -->


# Diagnostics Plots

## Normality Plots

![](figures/diagnostic-qqplots-1.png)<!-- -->

## Residual Plots

![](figures/diagnostic-residual-plots-1.png)<!-- -->

#  Endpoint Analysis


Table: Endpoint summary data.

Diet               Treatment        Body.Weight_mean   Lean.Mass_mean   Total.Fat.Mass_mean   Percent.Fat.Mass_mean
-----------------  --------------  -----------------  ---------------  --------------------  ----------------------
Normal Chow Diet   Dexamethasone            26.01667         22.25250              3.052500               11.667866
Normal Chow Diet   Water                    30.55833         27.14500              2.776667                9.188361
High Fat Diet      Dexamethasone            30.37500         19.92250              9.251667               30.379430
High Fat Diet      Water                    40.75000         25.96333             14.075000               34.151367

## Endpoint Barplots

![](figures/endpoint.barplots-1.png)<!-- -->

Table: ANOVA of endpoint Body Weights

term              df      sumsq       meansq   statistic     p.value
---------------  ---  ---------  -----------  ----------  ----------
Diet               1   635.1075   635.107500    85.18220   0.0000000
Treatment          1   667.5208   667.520833    89.52956   0.0000000
Diet:Treatment     1   102.0833   102.083333    13.69167   0.0005958
Residuals         44   328.0583     7.455871          NA          NA



Table: ANOVA of endpoint Fat-Free Mass

term              df        sumsq       meansq   statistic     p.value
---------------  ---  -----------  -----------  ----------  ----------
Diet               1    36.995408    36.995408    9.707451   0.0032270
Treatment          1   358.613333   358.613333   94.098741   0.0000000
Diet:Treatment     1     3.956008     3.956008    1.038041   0.3138471
Residuals         44   167.685417     3.811032          NA          NA



Table: ANOVA of endpoint Fat Mass

term              df       sumsq       meansq   statistic     p.value
---------------  ---  ----------  -----------  ----------  ----------
Diet               1   918.48752   918.487519   229.40687   0.0000000
Treatment          1    62.03927    62.039269    15.49529   0.0002908
Diet:Treatment     1    78.00450    78.004502    19.48286   0.0000649
Residuals         44   176.16496     4.003749          NA          NA

# Session Information


```
## R version 3.5.0 (2018-04-23)
## Platform: x86_64-apple-darwin15.6.0 (64-bit)
## Running under: macOS High Sierra 10.13.6
## 
## Matrix products: default
## BLAS: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRblas.0.dylib
## LAPACK: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRlapack.dylib
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] broom_0.5.0    ggplot2_3.0.0  gridExtra_2.3  lme4_1.1-18-1 
## [5] Matrix_1.2-14  bindrcpp_0.2.2 tidyr_0.8.1    dplyr_0.7.6   
## [9] knitr_1.20    
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.18     plyr_1.8.4       pillar_1.3.0     compiler_3.5.0  
##  [5] nloptr_1.0.4     highr_0.7        bindr_0.1.1      tools_3.5.0     
##  [9] digest_0.6.16    evaluate_0.11    tibble_1.4.2     nlme_3.1-137    
## [13] gtable_0.2.0     lattice_0.20-35  pkgconfig_2.0.2  rlang_0.2.2     
## [17] yaml_2.2.0       withr_2.1.2      stringr_1.3.1    rprojroot_1.3-2 
## [21] grid_3.5.0       tidyselect_0.2.4 glue_1.3.0       R6_2.2.2        
## [25] rmarkdown_1.10   minqa_1.2.4      purrr_0.2.5      magrittr_1.5    
## [29] backports_1.1.2  scales_1.0.0     htmltools_0.3.6  splines_3.5.0   
## [33] MASS_7.3-50      assertthat_0.2.0 colorspace_1.3-2 labeling_0.3    
## [37] stringi_1.2.4    lazyeval_0.2.1   munsell_0.5.0    crayon_1.3.4
```
