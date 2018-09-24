---
title: "Analysis of Tissue Weights from HFD/Dexamethasone Studies"
author: "Innocence Harvey and Dave Bridges"
date: "April 7, 2017"
output:
  html_document:
    toc: yes
    keep_md: yes
  htmin_notebook: toc:yes
  htmin_document:
    keep_md: yes
---



# Data Entry



This script generates figures from the tissue weights found in ../../data/raw/HFD and Chow Tissue Weights.csv.  This file is located in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity and was most recently updated on Mon Sep 24 15:29:15 2018.

# Number of Animals


Table: Number of mice in each group

Status   Diet   Treatment        Number
-------  -----  --------------  -------
Fasted   NCD    Water                 8
Fasted   NCD    Dexamethasone         8
Fasted   HFD    Water                22
Fasted   HFD    Dexamethasone        12
Fed      NCD    Water                 4
Fed      NCD    Dexamethasone         4

# Summary Data

The remainder of this analysis is only for Fasted animals


Table: Averaged Values

Diet   Treatment        iWAT_mean.na   eWAT_mean.na   TS_mean.na   Quad_mean.na
-----  --------------  -------------  -------------  -----------  -------------
NCD    Water                140.9750       187.1125     163.3750       240.0250
NCD    Dexamethasone        111.0625       173.1875     144.5000       197.8250
HFD    Water                840.7545      1136.3773     190.6905       241.7727
HFD    Dexamethasone        286.8000       464.1000     127.4417       139.5000

# Muscle Barplots

![](figures/muscle-weight-barplot-1.png)<!-- -->

# Adipose Barplots

![](figures/adipose-weight-barplot-1.png)<!-- -->

## Analysis of Adipose Tissue Weights

We observed reductions in both iWAT and eWAT with HFD/Dexamethasone.  

### Inguinal Adipose Tissue

This included a 65.8877848% reduction in iWAT mass in the HFD mice.  A Shapiro-Wilk test of the iWAT values had a p-value of >0.0621229, so normality could be assumed.  To test for equal variance, Levene's tests were performed.


The p-value from the Levene's test were 0.0041061 for HFD.  Based on this a Welch's *t* test was performed with a p-value of **4.4777019&times; 10^-7^**.  

For NCD the Levene's test had a p-value of and  0.2829918, so equal variance could be assumed.  Based on this, a Student's *t*-test had a p-value of **0.4967434** for NCD.


There was only a 21.2183011% reduction in iWAT mass in the NCD mice.



Based on a 2-way ANOVA with Diet and Group as the interacting covariates there was a significant interaction between diet and treatment:


Table: Two Way ANOVA with Interaction between treatment and diet.

term          df       sumsq       meansq   statistic    p.value
-----------  ---  ----------  -----------  ----------  ---------
Diet           1   3579646.8   3579646.80    65.49123   0.00e+00
Group          1   1400297.4   1400297.44    25.61906   5.20e-06
Diet:Group     1    983744.2    983744.15    17.99804   8.73e-05
Residuals     54   2951554.4     54658.42          NA         NA

The p-value for the interaction was **8.7281221&times; 10^-5^**.  The residuals of this model, passed through a Shapiro-Wilk test had a p-value of 0.0015701, so normality could not be assumed.

### Epididimal Adipose Tissue

This included a 59.1596901% reduction in eWAT mass in the HFD mice.

There was only a 7.4420469% reduction in eWAT mass in the NCD mice.






The p-value from the Levene's test were 0.0298476 for HFD.  Based on this a Welch's *t* test was performed with a p-value of **3.7377627&times; 10^-14^**.  

For NCD the Levene's test had a p-value of and  0.8965011, so equal variance could be assumed.  Based on this, a Student's *t*-test had a p-value of **0.5452112** for NCD.

Based on a 2-way ANOVA with Diet and Group as the interacting covariates there was a significant interaction between diet and treatment:


Table: Two Way ANOVA with Interaction between treatment and diet.

term          df     sumsq       meansq   statistic   p.value
-----------  ---  --------  -----------  ----------  --------
Diet           1   6924250   6924250.12   342.62891         0
Group          1   2055412   2055411.62   101.70682         0
Diet:Group     1   1455533   1455532.97    72.02335         0
Residuals     54   1091296     20209.18          NA        NA

The p-value for the interaction was **1.6294353&times; 10^-11^**.  The residuals of this model, passed through a Shapiro-Wilk test had a p-value of 0.0049698, so normality could not be assumed.

## Muscle Statistics

### Quadriceps Statistics





The p-value from the Levene's test were 0.3496128 for HFD.  Based on this a Student's *t* test was performed with a p-value of **9.2083744&times; 10^-14^**.  

For NCD the Levene's test had a p-value of and  0.2678086, so equal variance could be assumed.  Based on this, a Student's *t*-test had a p-value of **1.1220172&times; 10^-4^** for NCD.

Based on a 2-way ANOVA with Diet and Group as the interacting covariates there was a significant interaction between diet and treatment:


Table: Two Way ANOVA with Interaction between treatment and diet.

term          df       sumsq       meansq    statistic     p.value
-----------  ---  ----------  -----------  -----------  ----------
Diet           1    1736.884    1736.8838     3.356417   0.0724607
Group          1   80825.177   80825.1770   156.189509   0.0000000
Diet:Group     1   11714.471   11714.4710    22.637469   0.0000150
Residuals     54   27943.999     517.4815           NA          NA

The p-value for the interaction was **1.500917&times; 10^-5^**.  The residuals of this model, passed through a Shapiro-Wilk test had a p-value of 0.4281909, so normality could not be assumed.

### Triceps Surae Statistics





The p-value from the Levene's test were 0.6748082 for HFD.  Based on this a Student's *t* test was performed with a p-value of **3.8429279&times; 10^-8^**.  

For NCD the Levene's test had a p-value of and  0.1872348, so equal variance could be assumed.  Based on this, a Student's *t*-test had a p-value of **0.0153856** for NCD.

Based on a 2-way ANOVA with Diet and Group as the interacting covariates there was a significant interaction between diet and treatment:


Table: Two Way ANOVA with Interaction between treatment and diet.

term          df       sumsq       meansq   statistic     p.value
-----------  ---  ----------  -----------  ----------  ----------
Diet           1    2323.916    2323.9158    4.403715   0.0406426
Group          1   28745.921   28745.9206   54.472209   0.0000000
Diet:Group     1    5215.614    5215.6144    9.883351   0.0027316
Residuals     53   27969.011     527.7172          NA          NA

The p-value for the interaction was **0.0027316**.  The residuals of this model, passed through a Shapiro-Wilk test had a p-value of 2.3935765&times; 10^-5^, so normality could not be assumed.

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
## [1] broom_0.5.0    car_3.0-2      carData_3.0-1  bindrcpp_0.2.2
## [5] forcats_0.3.0  readr_1.1.1    dplyr_0.7.6    tidyr_0.8.1   
## [9] knitr_1.20    
## 
## loaded via a namespace (and not attached):
##  [1] zip_1.0.0         Rcpp_0.12.18      plyr_1.8.4       
##  [4] cellranger_1.1.0  pillar_1.3.0      compiler_3.5.0   
##  [7] highr_0.7         bindr_0.1.1       tools_3.5.0      
## [10] digest_0.6.16     lattice_0.20-35   nlme_3.1-137     
## [13] evaluate_0.11     tibble_1.4.2      pkgconfig_2.0.2  
## [16] rlang_0.2.2       openxlsx_4.1.0    curl_3.2         
## [19] yaml_2.2.0        haven_1.1.2       rio_0.5.10       
## [22] stringr_1.3.1     hms_0.4.2         grid_3.5.0       
## [25] rprojroot_1.3-2   tidyselect_0.2.4  glue_1.3.0       
## [28] data.table_1.11.4 R6_2.2.2          readxl_1.1.0     
## [31] foreign_0.8-71    rmarkdown_1.10    purrr_0.2.5      
## [34] magrittr_1.5      backports_1.1.2   htmltools_0.3.6  
## [37] abind_1.4-5       assertthat_0.2.0  stringi_1.2.4    
## [40] crayon_1.3.4
```
