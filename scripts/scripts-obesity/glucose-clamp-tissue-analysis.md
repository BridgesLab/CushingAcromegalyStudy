# Analysis of 2DG Uptake from HFD Glucose Clamp Tissues
Innocence Harvey and Dave Bridges  
2017-08-16  



# Purpose

# Experimental Details

Link to the protocol used (permalink preferred) for the experiment and include any notes relevant to your analysis.  This might include specifics not in the general protocol such as cell lines, treatment doses etc.

# Raw Data

The input data is extracted glucose uptake (nmol/g/min) from the clamp datafiles.



These data can be found in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity in a file named ../../data/raw/Clamp HFD tissue uptake data.csv.  This script was most recently updated on Wed Aug 16 17:41:11 2017.

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
## R version 3.3.0 (2016-05-03)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## Running under: OS X 10.12.6 (unknown)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] car_2.1-5    bindrcpp_0.2 readr_1.1.1  dplyr_0.7.2  tidyr_0.6.3 
## [6] knitr_1.17  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.12       bindr_0.1          magrittr_1.5      
##  [4] splines_3.3.0      hms_0.3            MASS_7.3-47       
##  [7] lattice_0.20-35    R6_2.2.2           rlang_0.1.2       
## [10] minqa_1.2.4        stringr_1.2.0      highr_0.6         
## [13] tools_3.3.0        parallel_3.3.0     grid_3.3.0        
## [16] pbkrtest_0.4-7     nnet_7.3-12        nlme_3.1-131      
## [19] mgcv_1.8-18        quantreg_5.33      MatrixModels_0.4-1
## [22] htmltools_0.3.6    lme4_1.1-13        yaml_2.1.14       
## [25] rprojroot_1.2      digest_0.6.12      assertthat_0.2.0  
## [28] tibble_1.3.3       Matrix_1.2-10      nloptr_1.0.4      
## [31] glue_1.1.1         evaluate_0.10.1    rmarkdown_1.6     
## [34] stringi_1.1.5      backports_1.1.0    SparseM_1.77      
## [37] pkgconfig_2.0.1
```

# References

If needed, using Rmarkdown citation tools (see this link for more information: http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
