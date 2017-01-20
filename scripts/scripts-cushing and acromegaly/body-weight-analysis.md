# Weight Analysis of Dexamethasone Treated C57BL/6J Mice
Innocence Harvey and Dave Bridges  
February 23, 2015  



# Data Entry
This was from combined weights over several measurements of C57BL/6J Mice on treated with dexamethasone.  Some animals may appear multiple times in this analysis.  Data is downloaded in csv format from the mousedb website.  This includes only fed weights.  These mice were treated with 10 mg/kg/day starting at 70 days of age.



Data was downloaded from MouseDB then aand the data is saved as ../data/raw/Body Composition Data.csv.  These data  was most recently updated on Tue Feb 24 12:56:40 2015.

# Body Weights

![](figures/weights-scatterplot-1.png) ![](figures/weights-scatterplot-2.png) 

# Lean Mass

![](figures/lean-mass-scatterplot-1.png) ![](figures/lean-mass-scatterplot-2.png) 

# Fat Mass

![](figures/fat-mass-scatterplot-1.png) ![](figures/fat-mass-scatterplot-2.png) 

![](figures/pct-fat-mass-scatterplot-1.png) ![](figures/pct-fat-mass-scatterplot-2.png) 

![](figures/pct-fat-mass-scatterplot-smooth-1.png) 

Based on a linear mixed effects model, the p-value for an effect of Dexamethasone on the rate of change in percent fat mass was 1.4727383\times 10^{-31} (Chi-squared=136.6029851) with an increase of 0.7717172\% per week.  To test for normality in this model we did a Shapiro-Wilk test and found that the did not meet this assumption 7.0586952\times 10^{-4}.

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
## [1] lme4_1.1-7   Rcpp_0.11.4  Matrix_1.1-5 dplyr_0.4.1  knitr_1.9   
## 
## loaded via a namespace (and not attached):
##  [1] assertthat_0.1   chron_2.3-45     data.table_1.9.4 DBI_0.3.1       
##  [5] digest_0.6.8     evaluate_0.5.5   formatR_1.0      grid_3.1.2      
##  [9] htmltools_0.2.6  lattice_0.20-29  lazyeval_0.1.10  magrittr_1.5    
## [13] MASS_7.3-37      minqa_1.2.4      nlme_3.1-119     nloptr_1.0.4    
## [17] parallel_3.1.2   plyr_1.8.1       reshape2_1.4.1   rmarkdown_0.5.1 
## [21] splines_3.1.2    stringr_0.6.2    tools_3.1.2      yaml_2.1.13
```
