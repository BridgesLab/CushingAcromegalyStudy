Analysis of IGF Data for Acromegaly Patients
=============================================================

These data compare the IGF levels with transcriptional changes.  This file was last compiled on ``Mon Oct 13 08:57:47 2014``.


```
## Warning: column name 'X' is duplicated in the result
```

We normalized the expression data, and calculated the correlation between IGF levels and transcript levels for the IGF patients only.

Correlation of IGF levels with IGF Related Transcripts
--------------------------------------------------------





```
## pdf 
##   2
```

## Barplots




```
## Warning: package 'xtable' was built under R version 3.1.1
```

<!-- html table generated in R 3.1.0 by xtable 1.7-4 package -->
<!-- Mon Oct 13 08:58:43 2014 -->
<table border=1>
<tr> <th>  </th> <th> Row.names </th> <th> rsq </th> <th> pval </th> <th> estimate </th> <th> padj </th> <th> hgnc_symbol </th>  </tr>
  <tr> <td align="right"> 1 </td> <td> ENSG00000017427 </td> <td align="right"> 0.622 </td> <td align="right"> 0.035 </td> <td align="right"> 0.016 </td> <td align="right"> 0.606 </td> <td> IGF1 </td> </tr>
  <tr> <td align="right"> 30 </td> <td> ENSG00000253869 </td> <td align="right"> 0.519 </td> <td align="right"> 0.068 </td> <td align="right"> 0.000 </td> <td align="right"> 0.606 </td> <td> PIGFP1 </td> </tr>
  <tr> <td align="right"> 15 </td> <td> ENSG00000151665 </td> <td align="right"> 0.472 </td> <td align="right"> 0.088 </td> <td align="right"> -0.001 </td> <td align="right"> 0.606 </td> <td> PIGF </td> </tr>
  <tr> <td align="right"> 13 </td> <td> ENSG00000146674 </td> <td align="right"> 0.446 </td> <td align="right"> 0.101 </td> <td align="right"> 0.023 </td> <td align="right"> 0.606 </td> <td> IGFBP3 </td> </tr>
  <tr> <td align="right"> 7 </td> <td> ENSG00000126246 </td> <td align="right"> 0.376 </td> <td align="right"> 0.143 </td> <td align="right"> -0.000 </td> <td align="right"> 0.647 </td> <td> IGFLR1 </td> </tr>
  <tr> <td align="right"> 32 </td> <td> ENSG00000268879 </td> <td align="right"> 0.350 </td> <td align="right"> 0.162 </td> <td align="right"> 0.000 </td> <td align="right"> 0.647 </td> <td> IGFL1P1 </td> </tr>
  <tr> <td align="right"> 17 </td> <td> ENSG00000163395 </td> <td align="right"> 0.238 </td> <td align="right"> 0.266 </td> <td align="right"> -0.000 </td> <td align="right"> 0.683 </td> <td> IGFN1 </td> </tr>
  <tr> <td align="right"> 4 </td> <td> ENSG00000099869 </td> <td align="right"> 0.194 </td> <td align="right"> 0.323 </td> <td align="right"> 0.000 </td> <td align="right"> 0.683 </td> <td> IGF2-AS </td> </tr>
  <tr> <td align="right"> 5 </td> <td> ENSG00000115457 </td> <td align="right"> 0.157 </td> <td align="right"> 0.378 </td> <td align="right"> -0.000 </td> <td align="right"> 0.683 </td> <td> IGFBP2 </td> </tr>
  <tr> <td align="right"> 3 </td> <td> ENSG00000099769 </td> <td align="right"> 0.154 </td> <td align="right"> 0.384 </td> <td align="right"> 0.000 </td> <td align="right"> 0.683 </td> <td> IGFALS </td> </tr>
  <tr> <td align="right"> 6 </td> <td> ENSG00000115461 </td> <td align="right"> 0.153 </td> <td align="right"> 0.385 </td> <td align="right"> 0.026 </td> <td align="right"> 0.683 </td> <td> IGFBP5 </td> </tr>
  <tr> <td align="right"> 11 </td> <td> ENSG00000140443 </td> <td align="right"> 0.151 </td> <td align="right"> 0.389 </td> <td align="right"> -0.000 </td> <td align="right"> 0.683 </td> <td> IGF1R </td> </tr>
  <tr> <td align="right"> 19 </td> <td> ENSG00000165197 </td> <td align="right"> 0.145 </td> <td align="right"> 0.400 </td> <td align="right"> -0.001 </td> <td align="right"> 0.683 </td> <td> FIGF </td> </tr>
  <tr> <td align="right"> 24 </td> <td> ENSG00000197081 </td> <td align="right"> 0.126 </td> <td align="right"> 0.435 </td> <td align="right"> -0.001 </td> <td align="right"> 0.683 </td> <td> IGF2R </td> </tr>
  <tr> <td align="right"> 16 </td> <td> ENSG00000159217 </td> <td align="right"> 0.120 </td> <td align="right"> 0.447 </td> <td align="right"> 0.000 </td> <td align="right"> 0.683 </td> <td> IGF2BP1 </td> </tr>
  <tr> <td align="right"> 10 </td> <td> ENSG00000137142 </td> <td align="right"> 0.116 </td> <td align="right"> 0.455 </td> <td align="right"> 0.000 </td> <td align="right"> 0.683 </td> <td> IGFBPL1 </td> </tr>
  <tr> <td align="right"> 21 </td> <td> ENSG00000167779 </td> <td align="right"> 0.048 </td> <td align="right"> 0.638 </td> <td align="right"> -0.004 </td> <td align="right"> 0.892 </td> <td> IGFBP6 </td> </tr>
  <tr> <td align="right"> 26 </td> <td> ENSG00000204869 </td> <td align="right"> 0.030 </td> <td align="right"> 0.709 </td> <td align="right"> -0.000 </td> <td align="right"> 0.892 </td> <td> IGFL4 </td> </tr>
  <tr> <td align="right"> 29 </td> <td> ENSG00000245067 </td> <td align="right"> 0.029 </td> <td align="right"> 0.714 </td> <td align="right"> -0.001 </td> <td align="right"> 0.892 </td> <td> IGFBP7-AS1 </td> </tr>
  <tr> <td align="right"> 2 </td> <td> ENSG00000073792 </td> <td align="right"> 0.023 </td> <td align="right"> 0.744 </td> <td align="right"> 0.000 </td> <td align="right"> 0.892 </td> <td> IGF2BP2 </td> </tr>
  <tr> <td align="right"> 12 </td> <td> ENSG00000141753 </td> <td align="right"> 0.001 </td> <td align="right"> 0.960 </td> <td align="right"> 0.001 </td> <td align="right"> 0.996 </td> <td> IGFBP4 </td> </tr>
  <tr> <td align="right"> 20 </td> <td> ENSG00000167244 </td> <td align="right"> 0.000 </td> <td align="right"> 0.976 </td> <td align="right"> -0.000 </td> <td align="right"> 0.996 </td> <td> IGF2 </td> </tr>
  <tr> <td align="right"> 18 </td> <td> ENSG00000163453 </td> <td align="right"> 0.000 </td> <td align="right"> 0.996 </td> <td align="right"> -0.000 </td> <td align="right"> 0.996 </td> <td> IGFBP7 </td> </tr>
  <tr> <td align="right"> 9 </td> <td> ENSG00000136231 </td> <td align="right"> 0.000 </td> <td align="right"> 0.996 </td> <td align="right"> 0.000 </td> <td align="right"> 0.996 </td> <td> IGF2BP3 </td> </tr>
  <tr> <td align="right"> 8 </td> <td> ENSG00000129965 </td> <td align="right">  </td> <td align="right">  </td> <td align="right"> -0.000 </td> <td align="right">  </td> <td> INS-IGF2 </td> </tr>
  <tr> <td align="right"> 14 </td> <td> ENSG00000146678 </td> <td align="right">  </td> <td align="right">  </td> <td align="right"> -0.000 </td> <td align="right">  </td> <td> IGFBP1 </td> </tr>
  <tr> <td align="right"> 22 </td> <td> ENSG00000188293 </td> <td align="right">  </td> <td align="right">  </td> <td align="right"> -0.000 </td> <td align="right">  </td> <td> IGFL1 </td> </tr>
  <tr> <td align="right"> 23 </td> <td> ENSG00000188624 </td> <td align="right">  </td> <td align="right">  </td> <td align="right"> -0.000 </td> <td align="right">  </td> <td> IGFL3 </td> </tr>
  <tr> <td align="right"> 25 </td> <td> ENSG00000204866 </td> <td align="right">  </td> <td align="right">  </td> <td align="right"> -0.000 </td> <td align="right">  </td> <td> IGFL2 </td> </tr>
  <tr> <td align="right"> 27 </td> <td> ENSG00000227592 </td> <td align="right">  </td> <td align="right">  </td> <td align="right"> -0.000 </td> <td align="right">  </td> <td> PIGFP3 </td> </tr>
  <tr> <td align="right"> 28 </td> <td> ENSG00000234881 </td> <td align="right">  </td> <td align="right">  </td> <td align="right"> -0.000 </td> <td align="right">  </td> <td> PIGFP2 </td> </tr>
  <tr> <td align="right"> 31 </td> <td> ENSG00000268238 </td> <td align="right">  </td> <td align="right">  </td> <td align="right"> -0.000 </td> <td align="right">  </td> <td> IGFL1P2 </td> </tr>
   </table>

Do IGF-1 Levels Correlate with Age
------------------------------------



```
## pdf 
##   2
```



Session Information
-------------------

```r
sessionInfo()
```

```
## R version 3.1.0 (2014-04-10)
## Platform: x86_64-apple-darwin13.1.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] xtable_1.7-4   plyr_1.8.1     reshape2_1.4   biomaRt_2.20.0
## [5] knitr_1.6     
## 
## loaded via a namespace (and not attached):
##  [1] AnnotationDbi_1.26.0 Biobase_2.24.0       BiocGenerics_0.10.0 
##  [4] DBI_0.3.0            evaluate_0.5.5       formatR_1.0         
##  [7] GenomeInfoDb_1.0.2   IRanges_1.22.10      parallel_3.1.0      
## [10] Rcpp_0.11.2          RCurl_1.95-4.3       RSQLite_0.11.4      
## [13] stats4_3.1.0         stringr_0.6.2        tools_3.1.0         
## [16] XML_3.98-1.1
```
