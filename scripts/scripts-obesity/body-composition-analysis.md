---
title: "Combined Analysis of HFD/NCD Dexamethasone Treatment"
author: "Innocence Harvey and Dave Bridges"
date: "April 1, 2015"
output:
  html_document:
    toc: yes
    keep_md: yes
---





This script uses the files in ../../data/raw/Normal Chow Diet Body Composition Data.csv and ../../data/raw/High Fat Diet Body Composition Data.csv.  These data are located in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity and this script was most recently run on Thu Apr  4 09:39:48 2019.  These data were written out in summary format to the file ../../data/processed/Summarized Body Composition Data.csv.

# Body Weights

![](figures/weights-scatterplot-1.png)<!-- -->


# Lean Mass

![](figures/lean-mass-scatterplot-1.png)<!-- -->

Table: Coefficients from mixed linear model of the interaction of time of dexamethasoen/water with Diet and Treatment

                                           Estimate   Std. Error          df       t value    Pr(>|t|)
--------------------------------------  -----------  -----------  ----------  ------------  ----------
(Intercept)                              24.4795309    0.5294003    51.25712    46.2401118   0.0000000
Time                                     -0.0693685    0.0055325   302.95081   -12.5383950   0.0000000
TreatmentWater                            2.1446927    0.7495919    51.50367     2.8611472   0.0060857
DietHigh Fat Diet                         0.1979265    0.7462057    50.58464     0.2652438   0.7918996
Time:TreatmentWater                       0.0825803    0.0079460   303.00906    10.3926384   0.0000000
Time:DietHigh Fat Diet                   -0.0663224    0.0078919   303.04816    -8.4038949   0.0000000
TreatmentWater:DietHigh Fat Diet         -1.5048021    1.0558381    50.68818    -1.4252205   0.1602224
Time:TreatmentWater:DietHigh Fat Diet     0.0736833    0.0110138   303.04178     6.6901174   0.0000000

A Chi-squared test between models with time and treatment interacting, with a model where diet modifies the rate of lean mass loss yielded a p-value of 6.3198413\times 10^{-14}.

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
## Running under: macOS  10.14.2
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
##  [1] broom_0.5.1    ggplot2_3.1.0  gridExtra_2.3  lmerTest_3.0-1
##  [5] lme4_1.1-19    Matrix_1.2-15  bindrcpp_0.2.2 tidyr_0.8.2   
##  [9] dplyr_0.7.8    knitr_1.21    
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.0        highr_0.7         plyr_1.8.4       
##  [4] pillar_1.3.1      compiler_3.5.0    nloptr_1.2.1     
##  [7] bindr_0.1.1       tools_3.5.0       digest_0.6.18    
## [10] evaluate_0.12     tibble_2.0.0      nlme_3.1-137     
## [13] gtable_0.2.0      lattice_0.20-38   pkgconfig_2.0.2  
## [16] rlang_0.3.1       yaml_2.2.0        xfun_0.4         
## [19] withr_2.1.2       stringr_1.3.1     generics_0.0.2   
## [22] grid_3.5.0        tidyselect_0.2.5  glue_1.3.0       
## [25] R6_2.3.0          rmarkdown_1.11    minqa_1.2.4      
## [28] purrr_0.2.5       magrittr_1.5      backports_1.1.3  
## [31] scales_1.0.0      htmltools_0.3.6   splines_3.5.0    
## [34] MASS_7.3-51.1     assertthat_0.2.0  colorspace_1.3-2 
## [37] numDeriv_2016.8-1 labeling_0.3      stringi_1.2.4    
## [40] lazyeval_0.2.1    munsell_0.5.0     crayon_1.3.4
```
