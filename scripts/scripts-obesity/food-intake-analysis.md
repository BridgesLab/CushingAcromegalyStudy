# Food Intake Analysis of NCD/HFD Dexamethasone Treated Animals
Dave Bridges and Innocence Harvey  
2017-08-08  



# Purpose

To test whether food intake is different betwen NCD and HFD animals treated with dexamethasone or water.

# Experimental Details

We monitored weekly food intake, at the cage level throughout the experiment

# Raw Data

Describe your raw data files, including what the columns mean (and what units they are in).



These data can be found in /Users/iharvey/Desktop/CushingAcromegalyStudy/scripts/scripts-obesity in a file named ../../data/raw/HFD and NCD Food Intake Data.csv.  This script was most recently updated on Mon Dec 18 10:05:56 2017.

# Analysis



We converted NCD and HFD in grams to kcal by these factors


Table: Energy Density of Diets

Diet    Calories per gram
-----  ------------------
NCD                  2.91
HFD                  4.73

## Weekly Data

![](figures/weekly-food-intake-1.png)<!-- -->

## Analysis on the Aggregate

![](figures/overall-food-intake-1.png)<!-- -->

### Aggregate Food Intake Statistics

To analyse these data, we first aggregated the average food intake per cage, assuming this did not change over time.


Table: Two-way ANOVA with Interaction for aggregated food intake.

term              df    sumsq   meansq   statistic   p.value
---------------  ---  -------  -------  ----------  --------
Diet               1    7.738    7.738       26.23     0.000
Treatment          1    0.354    0.354        1.20     0.276
Diet:Treatment     1    2.347    2.347        7.96     0.006
Residuals         96   28.324    0.295          NA        NA

Based on this ANOVA there was a significant interaction between diet and treatment, with HFD/Dexamethasone animals eating less food than HFD/Water animals.  We further analysed this via pairwiwse tests.


Table: Shapiro-Wilk test results for food intake groups

Diet   Treatment        Shapiro
-----  --------------  --------
NCD    Water              0.137
NCD    Dexamethasone      0.359
HFD    Water              0.563
HFD    Dexamethasone      0.438

Based on these tests, normality could be assumed for eachg group.


Based on Levene's tests, HFD (p=0.613) and NCD (p=0.71) could be assumed to have equal variance.

We therefore performed Student's *t*-tests with the following results


Table: Pairwise Student's t-test for the effects of dexamethasone on food intake

       estimate1   estimate2   statistic   p.value   parameter   conf.low   conf.high  method              alternative 
----  ----------  ----------  ----------  --------  ----------  ---------  ----------  ------------------  ------------
NCD         11.1        10.1        2.97     0.006          28      0.314       1.704  Two Sample t-test   two.sided   
HFD         13.5        15.0       -2.19     0.032          68     -2.928      -0.138  Two Sample t-test   two.sided   

The effects were significant in both cases, with HFD animals eating slightly more food (11.181% increase) and NCD animals eating slightly less (-9.082% decrease) food on a per calorie basis.

# Interpretation



# Session Information


```r
sessionInfo()
```

```
## R version 3.3.1 (2016-06-21)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## Running under: OS X 10.11.6 (El Capitan)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] car_2.1-4     broom_0.4.2   ggplot2_2.1.0 bindrcpp_0.2  forcats_0.2.0
## [6] readr_1.0.0   dplyr_0.7.4   tidyr_0.6.0   knitr_1.14   
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.7        nloptr_1.0.4       formatR_1.4       
##  [4] highr_0.6          plyr_1.8.4         bindr_0.1         
##  [7] tools_3.3.1        lme4_1.1-12        digest_0.6.10     
## [10] evaluate_0.9       tibble_1.3.4       gtable_0.2.0      
## [13] nlme_3.1-128       lattice_0.20-34    mgcv_1.8-15       
## [16] pkgconfig_2.0.1    rlang_0.1.4        Matrix_1.2-7.1    
## [19] psych_1.7.5        yaml_2.1.13        parallel_3.3.1    
## [22] SparseM_1.74       stringr_1.1.0      MatrixModels_0.4-1
## [25] grid_3.3.1         nnet_7.3-12        glue_1.2.0        
## [28] R6_2.1.3           foreign_0.8-67     rmarkdown_1.0     
## [31] minqa_1.2.4        reshape2_1.4.1     magrittr_1.5      
## [34] splines_3.3.1      scales_0.4.0       htmltools_0.3.5   
## [37] MASS_7.3-45        pbkrtest_0.4-6     assertthat_0.1    
## [40] mnormt_1.5-5       colorspace_1.2-6   quantreg_5.29     
## [43] labeling_0.3       stringi_1.1.2      munsell_0.4.3
```
