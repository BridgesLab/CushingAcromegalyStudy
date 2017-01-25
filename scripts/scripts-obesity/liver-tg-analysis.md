# Combined Analysis of HFD/NCD Dexamethasone Liver Triglycerides
Innocence Harvey and Dave Bridges  
October 21, 2015  





Table: Summary Statistics for Liver Triglycerides

Diet               Treatment        Liver.TG.mean   Liver.TG.se   Liver.TG.n
-----------------  --------------  --------------  ------------  -----------
Normal Chow Diet   Water                 0.970041      0.082078            8
Normal Chow Diet   Dexamethasone         0.609654      0.090098            8
High Fat Diet      Water                17.902117     12.681950            8
High Fat Diet      Dexamethasone       111.993689     12.532765           12

This script uses the files in ../../data/raw/Liver TG hfd and chow dex.csv. These data are located in /Users/davebrid/Documents/GitHub/CushingAcromegalyStudy/scripts/scripts-obesity and this script was most recently run on Wed Jan 25 13:41:17 2017.

![](figures/liver-tg-barplot-1.png)<!-- -->

We observed a 17.455019 fold increase with High Fat Diet and a 37.151731% decrease with dexamethasone in chow but a 114.452585 fold increase with High Fat Diet and Dexamethasone.


# Statistics



From a two-way ANOVA with an interaction, the interaction term was significant (p=0.000068):


Table: ANOVA for Liver Triglyceride Levels

                  Df    Sum Sq     Mean Sq   F value     Pr(>F)
---------------  ---  --------  ----------  --------  ---------
Diet               1   48107.9   48107.865   51.7625   0.000000
Treatment          1   23031.6   23031.618   24.7813   0.000021
Diet:Treatment     1   19464.4   19464.376   20.9430   0.000068
Residuals         32   29740.7     929.396        NA         NA

# Session Information


```
## R version 3.3.0 (2016-05-03)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## Running under: OS X 10.12.2 (unknown)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] tidyr_0.6.1    dplyr_0.5.0    xlsx_0.5.7     xlsxjars_0.6.1
## [5] rJava_0.9-8    knitr_1.15.1  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.9     assertthat_0.1  digest_0.6.11   rprojroot_1.1  
##  [5] R6_2.2.0        DBI_0.5-1       backports_1.0.4 magrittr_1.5   
##  [9] evaluate_0.10   highr_0.6       stringi_1.1.2   lazyeval_0.2.0 
## [13] rmarkdown_1.3   tools_3.3.0     stringr_1.1.0   yaml_2.1.14    
## [17] htmltools_0.3.5 tibble_1.2
```
