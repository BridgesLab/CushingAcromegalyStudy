---
title: "Analysis of 2DG Uptake from HFD Glucose Clamp Tissues"
author: "Innocence Harvey and Dave Bridges"
date: '2017-08-16'
output:
  html_document:
    toc: yes
    keep_md: yes
  pdf_document:
    highlight: tango
    keep_tex: yes
    number_sections: no
    toc: yes
---



# Purpose

# Experimental Details

Link to the protocol used (permalink preferred) for the experiment and include any notes relevant to your analysis.  This might include specifics not in the general protocol such as cell lines, treatment doses etc.

# Raw Data

The input data is extracted glucose uptake (nmol/g/min) from the clamp datafiles.



These data can be found in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity in a file named ../../data/raw/Clamp HFD tissue uptake data.csv.  This script was most recently updated on Thu Sep 12 09:18:21 2019.

# Analysis


Treatment         BW_mean   Gastroc_mean   Heart_mean   vWAT_mean   scWAT_mean   BAT_mean
--------------  ---------  -------------  -----------  ----------  -----------  ---------
Water            34.05455      127.09909     2913.243    28.05411     39.26952   1673.125
Dexamethasone    30.80000       40.81704     1905.398    25.80526     27.44161   1419.747

## Adipose and Muscle Tissue

![](figures/clamp-glucose-uptake-adipose-muscle-1.png)<!-- -->

## Statistics


Table: Shapiro-Wilk Tests

Treatment               BW     Gastroc       Heart        vWAT       scWAT         BAT
--------------  ----------  ----------  ----------  ----------  ----------  ----------
Water            0.0455959   0.6512470   0.6714639   0.6869895   0.0047864   0.9753073
Dexamethasone    0.5017064   0.0000341   0.2413769   0.2592101   0.5848611   0.1745121

### Epididymal WAT

There was a **8.0161288**% decreasein eWAT glucose uptake.  These data could be assumed to be normally distributed (p=0.2592101).  A Levene's test showed the data could be assumed to have equal variation (p=0.8041117) so a Student's *t*-test was done, which had a p-value of **0.4555776**.

### Inguinal WAT

There was a **30.119802**% decrease in iWAT glucose uptake.  These data could not be assumed to be normally so Mann-Whitney test was done, which had a p-value of **0.0507161**.

### Gastrocnemieus

There was a **67.885655**% decrease in gastrocnemius glucose uptake.  These data could not be assumed to be normally so Mann-Whitney test was done, which had a p-value of **2.0191143&times; 10^-5^**.

### Heart

There was a **34.5952856**% decreasein heart glucose uptake.  These data could be assumed to be normally distributed (p=0.2413769).  A Levene's test showed the data could be assumed to have equal variation (p=0.9900442) so a Student's *t*-test was done, which had a p-value of **2.8456753&times; 10^-4^**.

### Brown Adipose Tissue

There was a **15.1439827**% decreasein BAT glucose uptake.  These data could be assumed to be normally distributed (p=0.1745121).  A Levene's test showed the data could be assumed to have equal variation (p=0.9344637) so a Student's *t*-test was done, which had a p-value of **0.3498177**.


![](figures/clamp-glucose-uptake-heart-bat-1.png)<!-- -->

# Interpretation

Reduced glucose uptake in 

# Session Information


```r
sessionInfo()
```

```
## R version 3.5.0 (2018-04-23)
## Platform: x86_64-apple-darwin15.6.0 (64-bit)
## Running under: macOS  10.14.6
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
## [1] car_3.0-3        carData_3.0-2    readr_1.3.1      dplyr_0.8.3     
## [5] tidyr_0.8.3.9000 knitr_1.23      
## 
## loaded via a namespace (and not attached):
##  [1] zip_2.0.2         Rcpp_1.0.1        cellranger_1.1.0 
##  [4] pillar_1.4.2      compiler_3.5.0    highr_0.8        
##  [7] forcats_0.4.0     tools_3.5.0       zeallot_0.1.0    
## [10] digest_0.6.20     evaluate_0.14     tibble_2.1.3     
## [13] pkgconfig_2.0.2   rlang_0.4.0       openxlsx_4.1.0.1 
## [16] curl_3.3          yaml_2.2.0        haven_2.1.0      
## [19] xfun_0.7          rio_0.5.16        stringr_1.4.0    
## [22] vctrs_0.2.0       hms_0.4.2         tidyselect_0.2.5 
## [25] glue_1.3.1        data.table_1.12.2 R6_2.4.0         
## [28] readxl_1.3.1      foreign_0.8-71    rmarkdown_1.13   
## [31] purrr_0.3.2       magrittr_1.5      backports_1.1.4  
## [34] htmltools_0.3.6   abind_1.4-5       assertthat_0.2.1 
## [37] stringi_1.4.3     crayon_1.3.4
```

# References

If needed, using Rmarkdown citation tools (see this link for more information: http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
