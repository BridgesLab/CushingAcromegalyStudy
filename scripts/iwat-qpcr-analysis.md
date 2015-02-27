# Analysis of iWAT mRNA Transcripts
Innocence Harvey and Dave Bridges  
February 25, 2015  



# Data Entry




Data was read from the file ../data/raw/iWAT qPCR Summary.csv.  These data were most recently updated on Fri Feb 27 10:17:36 2015.

#Analysis



<!-- html table generated in R 3.1.2 by xtable 1.7-4 package -->
<!-- Fri Feb 27 10:17:39 2015 -->
<table border=1>
<caption align="bottom"> Pairwise statistics summary, p-values adjusted by BH </caption>
<tr> <th>  </th> <th> shapiro-water </th> <th> shapiro-dex </th> <th> levene </th> <th> Test </th> <th> pval </th> <th> padj </th> <th> Significant </th>  </tr>
  <tr> <td align="right"> Acaca </td> <td align="right"> 0.004 </td> <td align="right"> 0.970 </td> <td align="right"> 0.471 </td> <td> Wilcoxon </td> <td align="right"> 0.018 </td> <td align="right"> 0.070 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Aco1 </td> <td align="right"> 0.253 </td> <td align="right"> 0.152 </td> <td align="right"> 0.073 </td> <td> Student </td> <td align="right"> 0.195 </td> <td align="right"> 0.260 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Acsl1 </td> <td align="right"> 0.068 </td> <td align="right"> 0.306 </td> <td align="right"> 0.006 </td> <td> Welchs </td> <td align="right"> 0.129 </td> <td align="right"> 0.193 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Acss2 </td> <td align="right"> 0.018 </td> <td align="right"> 0.131 </td> <td align="right"> 0.304 </td> <td> Wilcoxon </td> <td align="right"> 0.412 </td> <td align="right"> 0.449 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Agpat2 </td> <td align="right"> 0.664 </td> <td align="right"> 0.054 </td> <td align="right"> 0.652 </td> <td> Student </td> <td align="right"> 0.059 </td> <td align="right"> 0.133 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Dgat2 </td> <td align="right"> 0.818 </td> <td align="right"> 0.550 </td> <td align="right"> 0.331 </td> <td> Student </td> <td align="right"> 0.031 </td> <td align="right"> 0.094 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Dhcr24 </td> <td align="right"> 0.000 </td> <td align="right"> 0.087 </td> <td align="right"> 0.138 </td> <td> Wilcoxon </td> <td align="right"> 0.003 </td> <td align="right"> 0.047 </td> <td> TRUE </td> </tr>
  <tr> <td align="right"> Dhcr7 </td> <td align="right"> 0.003 </td> <td align="right"> 0.513 </td> <td align="right"> 0.423 </td> <td> Wilcoxon </td> <td align="right"> 0.018 </td> <td align="right"> 0.070 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Fasn </td> <td align="right"> 0.002 </td> <td align="right"> 0.190 </td> <td align="right"> 0.707 </td> <td> Wilcoxon </td> <td align="right"> 0.226 </td> <td align="right"> 0.285 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Gpam </td> <td align="right"> 0.053 </td> <td align="right"> 0.353 </td> <td align="right"> 0.587 </td> <td> Student </td> <td align="right"> 0.005 </td> <td align="right"> 0.047 </td> <td> TRUE </td> </tr>
  <tr> <td align="right"> Gpd1 </td> <td align="right"> 0.001 </td> <td align="right"> 0.123 </td> <td align="right"> 0.437 </td> <td> Wilcoxon </td> <td align="right"> 0.006 </td> <td align="right"> 0.047 </td> <td> TRUE </td> </tr>
  <tr> <td align="right"> Idh1 </td> <td align="right"> 0.207 </td> <td align="right"> 0.144 </td> <td align="right"> 0.024 </td> <td> Welchs </td> <td align="right"> 0.083 </td> <td align="right"> 0.133 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Ldhb </td> <td align="right"> 0.064 </td> <td align="right"> 0.087 </td> <td align="right"> 0.868 </td> <td> Student </td> <td align="right"> 0.009 </td> <td align="right"> 0.057 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Mdh1 </td> <td align="right"> 0.080 </td> <td align="right"> 0.889 </td> <td align="right"> 0.164 </td> <td> Student </td> <td align="right"> 0.076 </td> <td align="right"> 0.133 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Me1 </td> <td align="right"> 0.024 </td> <td align="right"> 0.162 </td> <td align="right"> 0.696 </td> <td> Wilcoxon </td> <td align="right"> 0.078 </td> <td align="right"> 0.133 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Nr3c1 </td> <td align="right"> 0.311 </td> <td align="right"> 0.359 </td> <td align="right"> 0.363 </td> <td> Student </td> <td align="right"> 0.403 </td> <td align="right"> 0.449 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Psmd1 </td> <td align="right"> 0.011 </td> <td align="right"> 0.117 </td> <td align="right"> 0.786 </td> <td> Wilcoxon </td> <td align="right"> 0.078 </td> <td align="right"> 0.133 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Psmd8 </td> <td align="right"> 0.085 </td> <td align="right"> 0.030 </td> <td align="right"> 0.461 </td> <td> Student </td> <td align="right"> 0.073 </td> <td align="right"> 0.133 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Rplp0 </td> <td align="right"> 0.053 </td> <td align="right"> 0.016 </td> <td align="right"> 0.191 </td> <td> Student </td> <td align="right"> 0.036 </td> <td align="right"> 0.096 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Rplp13a </td> <td align="right"> 0.381 </td> <td align="right"> 0.863 </td> <td align="right"> 0.957 </td> <td> Student </td> <td align="right"> 0.542 </td> <td align="right"> 0.565 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Scd1 </td> <td align="right"> 0.005 </td> <td align="right"> 0.021 </td> <td align="right"> 0.208 </td> <td> Wilcoxon </td> <td align="right"> 0.191 </td> <td align="right"> 0.260 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Scd2 </td> <td align="right"> 0.000 </td> <td align="right"> 0.534 </td> <td align="right"> 0.749 </td> <td> Wilcoxon </td> <td align="right"> 0.026 </td> <td align="right"> 0.090 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Scd3 </td> <td align="right"> 0.019 </td> <td align="right"> 0.004 </td> <td align="right"> 0.338 </td> <td> Wilcoxon </td> <td align="right"> 0.851 </td> <td align="right"> 0.851 </td> <td> FALSE </td> </tr>
  <tr> <td align="right"> Scd4 </td> <td align="right"> 0.000 </td> <td align="right"> 0.087 </td> <td align="right"> 0.547 </td> <td> Wilcoxon </td> <td align="right"> 0.412 </td> <td align="right"> 0.449 </td> <td> FALSE </td> </tr>
   </table>

## Lipogenic Genes

![](figures/iwat-lipogenic-genes-1.png) 

# Proteasome Genes

![](figures/iwat-proteosome-genes-1.png) 

# TCA Cycle Genes
![](figures/iwat-tca-genes-1.png) 

# Glucocorticoid Receptor
![](figures/iwat-glucocorticoid-receptor-1.png) 

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
## [1] reshape2_1.4.1 xtable_1.7-4   car_2.0-24     dplyr_0.4.1   
## [5] knitr_1.9     
## 
## loaded via a namespace (and not attached):
##  [1] assertthat_0.1  DBI_0.3.1       digest_0.6.8    evaluate_0.5.5 
##  [5] formatR_1.0     grid_3.1.2      htmltools_0.2.6 lattice_0.20-29
##  [9] lazyeval_0.1.10 lme4_1.1-7      magrittr_1.5    MASS_7.3-37    
## [13] Matrix_1.1-5    mgcv_1.8-4      minqa_1.2.4     nlme_3.1-119   
## [17] nloptr_1.0.4    nnet_7.3-8      parallel_3.1.2  pbkrtest_0.4-2 
## [21] plyr_1.8.1      quantreg_5.11   Rcpp_0.11.4     rmarkdown_0.5.1
## [25] SparseM_1.6     splines_3.1.2   stringr_0.6.2   tools_3.1.2    
## [29] yaml_2.1.13
```
