# Quantification of protein levels from 3T3-L1 Adipocytes
Innocence Harvey and Dave Bridges  
2017-08-16  



# Purpose

# Experimental Details

Mature 3T3-L1 adipocytes were treated with dexamethasone for 48h.

# Raw Data

The input data is the quantified band intensities.



These data can be found in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity in a file named ../../data/raw/3T3-L1 Blot Quantification.csv.  This script was most recently updated on Sun Sep  3 07:10:51 2017.

# Analysis


Table: Raw and normalized data

Treatment           ATGL    GAPDH  Experiment    ATGL.Revert    Revert   Normalized.Levels   Relative.Levels
--------------  --------  -------  -----------  ------------  --------  ------------------  ----------------
Vehicle           318500   855000  1                    6505   2815000               0.002              1.00
Vehicle           327000   945500  2                    4820   2735000               0.002              1.00
Dexamethasone    1170000   803000  1                   19600   2450000               0.008              3.46
Dexamethasone    1333333   929000  2                   21300   2370000               0.009              5.10
Vehicle            12900    44600  3                   12900     84700               0.152              1.00
Dexamethasone      35800     7230  3                   35800     61900               0.578              3.80



Table: Summary data

Treatment        mean      se   length
--------------  -----  ------  -------
Vehicle          1.00   0.000        3
Dexamethasone    4.12   0.499        3

![](figures/3T3-L1-ATGL-quantification-1.png)<!-- -->

These data were normalized to total protein stain (Revert) but GAPDH levels were determined as well.

## Statistics

The relative data could be assumed to be normally distributed via Shapiro-Wilk test (p=0.373), so we did a one-way *t*-test relative to a value of 1.  This yielded a p-value of **0.025**

# Interpretation

ATGL levels were significantly higher in 3T3-L1 adipocytes after dexamethasone treatment.

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
## [1] bindrcpp_0.2 readr_1.1.1  dplyr_0.7.2  tidyr_0.6.3  knitr_1.17  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.12     assertthat_0.2.0 digest_0.6.12    rprojroot_1.2   
##  [5] R6_2.2.2         backports_1.1.0  magrittr_1.5     evaluate_0.10.1 
##  [9] highr_0.6        rlang_0.1.2      stringi_1.1.5    rmarkdown_1.6   
## [13] tools_3.3.0      stringr_1.2.0    glue_1.1.1       hms_0.3         
## [17] yaml_2.1.14      pkgconfig_2.0.1  htmltools_0.3.6  bindr_0.1       
## [21] tibble_1.3.3
```
