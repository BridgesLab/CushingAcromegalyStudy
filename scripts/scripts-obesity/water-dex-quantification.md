---
title: "Analysis of Water and Dexamethasone Intake in NCD/HFD Mice"
author: "Innocence Harvey and Dave Bridges"
date: "March 5, 2018"
bibliography: "references.bib"
output:
  html_document:
    highlight: tango
    keep_md: yes
    number_sections: yes
    toc: yes
  pdf_document:
    highlight: tango
    keep_tex: yes
    number_sections: yes
    toc: yes
---



# Purpose

# Experimental Details



Dexamethasone was dissolved in water at a concentration of 3.78 ug/mL and animals were given *ad libitum* access.  Water bottle volumes were determined weekly.

# Raw Data

The input file contains tracked water and dexamethasone amounts per week.  The data includes the staring and ending volumes each week and a calculation of animals per week.



These data can be found in **/Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity** in a file named **no file found**.  This script was most recently updated on **Tue Jan  7 11:25:17 2020**.

# Analysis

This analysis only includes water/dex intake data from the Harvey et al studies, the dataset includes data from the Gunder et al studies but those are filtered out.

## Weekly Analysis

![](figures/weekly-lineplot-1.png)<!-- -->![](figures/weekly-lineplot-2.png)<!-- -->

## Average Analysis


Table: Average dexamethasone intake per group, averaged accross the experiment

Diet               Treatment        Intake.mean   Intake.se    n
-----------------  --------------  ------------  ----------  ---
Normal Chow Diet   Water                    0.0        0.00    3
Normal Chow Diet   Dexamethasone           22.8        1.87    4
High Fat Diet      Water                    0.0        0.00    4
High Fat Diet      Dexamethasone           40.5        1.82    5

![](figures/average-lineplot-1.png)<!-- -->

# Normalization to Body Weight



Loaded body summary composition data from ../../data/processed/Summarized Body Composition Data.csv.  Divided the average weekly intakes by the average weekly body weights.




## Normalized Intake - Weekly Analysis

![](figures/weekly-normalized-intake-1.png)<!-- -->

## Normalized Intake - Averaged Analysis


Table: Average dexamethasone intake per group normalized by body weight, averaged accross the experiment

Diet               Treatment        Agg.Intake.mean   Agg.Intake.se
-----------------  --------------  ----------------  --------------
Normal Chow Diet   Dexamethasone              0.796           0.065
Normal Chow Diet   Water                      0.000           0.000
High Fat Diet      Dexamethasone              1.158           0.093
High Fat Diet      Water                      0.000           0.000

![](figures/average-normalized-lineplot-1.png)<!-- -->

# Interpretation

The HFD animals had **1.778** fold more fluid intake than the NCD animals over the course of the experiment.  

Once normalized to body weight, the HFD animals had **45.466%** higher dexamethasone intake.

## Relationship to Human Doses



In general, according to @Nair_2016 we can predict that we should divide the mouse dose by 12.3 to get an equivalent human dose.


Table: Effective human dose in ug/kg/day

Diet               Treatment        Human.dose
-----------------  --------------  -----------
Normal Chow Diet   Dexamethasone          64.7
Normal Chow Diet   Water                   0.0
High Fat Diet      Dexamethasone          94.1
High Fat Diet      Water                   0.0

For a 70 kg human that is an effective dose range of **4.529** to **6.588** mg

# Serum Dexamethasone Assay

This assay was done by the pharmacokinetics core at UM and values were reported.  BLC indicated below cutoff, these values were assumed to be zero for this analysis



The dexamethasone quantification data is found in ../../data/raw/dexamethasone-quantification.csv.

![](figures/dex-boxplot-1.png)<!-- -->


Table: Summary Data for Dexamethasone Levels

Diet    Dex.mean   Dex.se   Dex.shapiro
-----  ---------  -------  ------------
NCD         1.61    0.666         0.017
HFD        12.22    3.686         0.223

![](figures/dex-barplot-1.png)<!-- -->

We observed a 7.585 fold increase in serum dexamethasone levels in the High Fat Diet fed animals.  Based on Shapiro-Wilk tests, we cannot assume normality, so we did a Mann Whitney test, which yielded a p-value of 0.031.


# Session Information


```r
sessionInfo()
```

```
## R version 3.5.0 (2018-04-23)
## Platform: x86_64-apple-darwin15.6.0 (64-bit)
## Running under: macOS  10.15.2
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
## [1] ggplot2_3.1.1       forcats_0.4.0       readr_1.3.1        
## [4] knitcitations_1.0.9 dplyr_0.8.3         tidyr_0.8.3.9000   
## [7] knitr_1.23         
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_1.0.1        highr_0.8         pillar_1.4.2     
##  [4] compiler_3.5.0    plyr_1.8.4        tools_3.5.0      
##  [7] zeallot_0.1.0     digest_0.6.20     jsonlite_1.6     
## [10] lubridate_1.7.4   evaluate_0.14     tibble_2.1.3     
## [13] gtable_0.3.0      pkgconfig_2.0.2   rlang_0.4.0      
## [16] bibtex_0.4.2      curl_3.3          yaml_2.2.0       
## [19] xfun_0.7          withr_2.1.2       RefManageR_1.2.12
## [22] stringr_1.4.0     httr_1.4.0        xml2_1.2.0       
## [25] vctrs_0.2.0       hms_0.4.2         grid_3.5.0       
## [28] tidyselect_0.2.5  glue_1.3.1        R6_2.4.0         
## [31] rmarkdown_1.13    reshape2_1.4.3    purrr_0.3.2      
## [34] magrittr_1.5      scales_1.0.0      backports_1.1.4  
## [37] htmltools_0.4.0   assertthat_0.2.1  colorspace_1.4-1 
## [40] labeling_0.3      stringi_1.4.3     lazyeval_0.2.2   
## [43] munsell_0.5.0     crayon_1.3.4
```

# References


