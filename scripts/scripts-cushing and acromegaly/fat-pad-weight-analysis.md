# Analysis of Gastroc mRNA Transcripts
Innocence Harvey and Dave Bridges  
February 25, 2015  



# Data Entry




Data was read from the file ../data/raw/Fat Pad Weights.csv.  These data were most recently updated on Fri Feb 27 13:24:20 2015.

#Analysis




For IWAT, a shapiro test had a p-value of >0.5782927.  A Levene's test had a p-value of 0.6243632 so we did a Student's *t*-test which yielded a p-value of 0.0411231.

![](figures/iwat-normalized-1.png) 


# Session Information


```
## R version 3.1.2 (2014-10-31)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] car_2.0-24  dplyr_0.4.1 knitr_1.9  
## 
## loaded via a namespace (and not attached):
##  [1] assertthat_0.1  DBI_0.3.1       digest_0.6.8    evaluate_0.5.5 
##  [5] formatR_1.0     grid_3.1.2      htmltools_0.2.6 lattice_0.20-29
##  [9] lazyeval_0.1.10 lme4_1.1-7      magrittr_1.5    MASS_7.3-37    
## [13] Matrix_1.1-5    mgcv_1.8-4      minqa_1.2.4     nlme_3.1-119   
## [17] nloptr_1.0.4    nnet_7.3-8      parallel_3.1.2  pbkrtest_0.4-2 
## [21] quantreg_5.11   Rcpp_0.11.4     rmarkdown_0.5.1 SparseM_1.6    
## [25] splines_3.1.2   stringr_0.6.2   tools_3.1.2     yaml_2.1.13
```
