# Integration with GSE26123
Dave Bridges  
February 18, 2015  



This analysis looked at the subcutaneous insulin and insulin/dex treated adipose explants described in:

Lee M-J, Gong D-W, Burkey BF, Fried SK (2011) Pathways regulated by glucocorticoids in omental and subcutaneous human adipose tissues: a microarray study. Am J Physiol Endocrinol Metab 300: E571–E580. doi:10.1152/ajpendo.00231.2010.

We did not examine omental fat.  This script was generated using GEO2R



According to our re-analysis of these data, there were no genes that were significant at a p-value of 0.05.  Using a less stingent p-value of 0.25 showed 18 significantly differentially expressed genes.  These genes are listed below:

<!-- html table generated in R 3.1.2 by xtable 1.7-4 package -->
<!-- Wed Feb 18 12:24:28 2015 -->
<table border=1>
<tr> <th>  </th> <th> Gene.symbol </th> <th> logFC </th> <th> P.Value </th> <th> adj.P.Val </th>  </tr>
  <tr> <td align="right"> 11462 </td> <td> STC1 </td> <td align="right"> 5.06 </td> <td align="right"> 0.00 </td> <td align="right"> 0.07 </td> </tr>
  <tr> <td align="right"> 4993 </td> <td> PLXDC1 </td> <td align="right"> 4.97 </td> <td align="right"> 0.00 </td> <td align="right"> 0.07 </td> </tr>
  <tr> <td align="right"> 77 </td> <td> PTGS2 </td> <td align="right"> 4.71 </td> <td align="right"> 0.00 </td> <td align="right"> 0.09 </td> </tr>
  <tr> <td align="right"> 6833 </td> <td> CYP1A1 </td> <td align="right"> -4.70 </td> <td align="right"> 0.00 </td> <td align="right"> 0.09 </td> </tr>
  <tr> <td align="right"> 5424 </td> <td> CXCL8 </td> <td align="right"> 4.60 </td> <td align="right"> 0.00 </td> <td align="right"> 0.09 </td> </tr>
  <tr> <td align="right"> 5891 </td> <td> AZGP1 </td> <td align="right"> -4.59 </td> <td align="right"> 0.00 </td> <td align="right"> 0.09 </td> </tr>
  <tr> <td align="right"> 3303 </td> <td> SAA1 </td> <td align="right"> -4.59 </td> <td align="right"> 0.00 </td> <td align="right"> 0.09 </td> </tr>
  <tr> <td align="right"> 6569 </td> <td> CASQ2 </td> <td align="right"> -4.49 </td> <td align="right"> 0.00 </td> <td align="right"> 0.11 </td> </tr>
  <tr> <td align="right"> 4419 </td> <td> ATP1A2 </td> <td align="right"> -4.47 </td> <td align="right"> 0.00 </td> <td align="right"> 0.11 </td> </tr>
  <tr> <td align="right"> 8509 </td> <td> MMP1 </td> <td align="right"> 4.42 </td> <td align="right"> 0.00 </td> <td align="right"> 0.11 </td> </tr>
  <tr> <td align="right"> 9739 </td> <td> CACNB2 </td> <td align="right"> -4.40 </td> <td align="right"> 0.00 </td> <td align="right"> 0.11 </td> </tr>
  <tr> <td align="right"> 7420 </td> <td> HMGN3 </td> <td align="right"> -4.39 </td> <td align="right"> 0.00 </td> <td align="right"> 0.11 </td> </tr>
  <tr> <td align="right"> 2562 </td> <td> TF </td> <td align="right"> -4.32 </td> <td align="right"> 0.00 </td> <td align="right"> 0.13 </td> </tr>
  <tr> <td align="right"> 5448 </td> <td> HAS2 </td> <td align="right"> 4.29 </td> <td align="right"> 0.00 </td> <td align="right"> 0.13 </td> </tr>
  <tr> <td align="right"> 9725 </td> <td> MMP13 </td> <td align="right"> 4.28 </td> <td align="right"> 0.00 </td> <td align="right"> 0.13 </td> </tr>
  <tr> <td align="right"> 4453 </td> <td> MVD </td> <td align="right"> -4.19 </td> <td align="right"> 0.00 </td> <td align="right"> 0.16 </td> </tr>
  <tr> <td align="right"> 10025 </td> <td> EPHB6 </td> <td align="right"> -4.18 </td> <td align="right"> 0.00 </td> <td align="right"> 0.16 </td> </tr>
  <tr> <td align="right"> 4816 </td> <td> MAP3K8 </td> <td align="right"> 4.10 </td> <td align="right"> 0.00 </td> <td align="right"> 0.20 </td> </tr>
   </table>

# Session Information

```
## R version 3.1.2 (2014-10-31)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] parallel  stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
## [1] xtable_1.7-4        limma_3.20.9        GEOquery_2.30.1    
## [4] Biobase_2.24.0      BiocGenerics_0.10.0 knitr_1.9          
## 
## loaded via a namespace (and not attached):
##  [1] bitops_1.0-6    digest_0.6.8    evaluate_0.5.5  formatR_1.0    
##  [5] htmltools_0.2.6 RCurl_1.95-4.5  rmarkdown_0.5.1 stringr_0.6.2  
##  [9] tools_3.1.2     XML_3.98-1.1    yaml_2.1.13
```
