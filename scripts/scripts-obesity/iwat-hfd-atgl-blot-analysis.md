# Combined Analysis of HFD/NCD Dexamethasone WAT ATGL Levels
Innocence Harvey and Dave Bridges  
February 11, 2016  





Table: Blot summary values

Diet               Treatment        mean      se   length   shapiro.p
-----------------  --------------  -----  ------  -------  ----------
Normal Chow Diet   Water            1.00   0.298        6       0.094
Normal Chow Diet   Dexamethasone    1.57   0.307        6       0.036
High Fat Diet      Water            1.85   0.217        4       0.690
High Fat Diet      Dexamethasone    6.87   1.659        6       0.570


This script uses the files in ../../data/raw/iWAT  HFD vs Chow Blot Quantification.xlsx and used the worksheet Sheet2. These data are located in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity and this script was most recently run on Wed Aug 16 15:26:39 2017.

![](figures/atgl-wat-barplot-1.png)<!-- -->

# Statistics



From a two-way ANOVA with an interaction, the interaction term was significant **p=0.033**:


Table: ANOVA for WAT ATGL Levels

                  Df   Sum Sq   Mean Sq   F value    Pr(>F)
---------------  ---  -------  --------  --------  --------
Diet               1     69.8     69.79     14.18   0.00142
Treatment          1     34.9     34.93      7.10   0.01581
Diet:Treatment     1     26.3     26.30      5.34   0.03287
Residuals         18     88.6      4.92        NA        NA

Tukey's tests (pairwise  comparasons are):


Table: Tukey's HSD tests for iWAT ATGL Levels

                                                               diff     lwr    upr     p adj
-----------------------------------------------------------  ------  ------  -----  --------
High Fat Diet:Water-Normal Chow Diet:Water                     0.86   -3.19   4.90   0.93157
Normal Chow Diet:Dexamethasone-Normal Chow Diet:Water          0.57   -3.05   4.19   0.96980
High Fat Diet:Dexamethasone-Normal Chow Diet:Water             5.87    2.25   9.49   0.00121
Normal Chow Diet:Dexamethasone-High Fat Diet:Water            -0.29   -4.33   3.76   0.99708
High Fat Diet:Dexamethasone-High Fat Diet:Water                5.01    0.96   9.06   0.01247
High Fat Diet:Dexamethasone-Normal Chow Diet:Dexamethasone     5.30    1.68   8.92   0.00318

# Session Information


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
## [1] bindrcpp_0.2   tidyr_0.6.3    dplyr_0.7.2    xlsx_0.5.7    
## [5] xlsxjars_0.6.1 rJava_0.9-8    knitr_1.17    
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.12     assertthat_0.2.0 digest_0.6.12    rprojroot_1.2   
##  [5] R6_2.2.2         backports_1.1.0  magrittr_1.5     evaluate_0.10.1 
##  [9] highr_0.6        rlang_0.1.2      stringi_1.1.5    rmarkdown_1.6   
## [13] tools_3.3.0      stringr_1.2.0    glue_1.1.1       yaml_2.1.14     
## [17] pkgconfig_2.0.1  htmltools_0.3.6  bindr_0.1        tibble_1.3.3
```
