---
title: "BMIasConfounder"
author: "Quynh Tran"
date: "July 24, 2014"
output: html_document
---

This is to check if BMI is a confouding factor between disease and gene expressions.





The counts tables were generated previously using  **HTseq.sh** shell script and **merge.command** on Hera.  It removes the outlier data point from the analysis, which was patient **29**.
This script requires a transcript counts table.  There is also a sample mapping file called **patient_sample_mapping.csv** which links the diagnosis the the samples.  This file was most recently processed on ``Thu Aug  7 13:20:45 2014``.



This step gets the protein coding genes only.




Full Analysis
--------------

![plot of chunk deseq-analysis adjusting for age](figure/deseq-analysis adjusting for age1.pdf) 

```
## [1] 35
```

```
##  [1] "Intercept"                  "BMI.0.25."                 
##  [3] "BMI.25.30."                 "BMI.30.50."                
##  [5] "groupControl"               "groupAcromegaly"           
##  [7] "BMI.0.25..groupControl"     "BMI.25.30..groupControl"   
##  [9] "BMI.30.50..groupControl"    "BMI.0.25..groupAcromegaly" 
## [11] "BMI.25.30..groupAcromegaly" "BMI.30.50..groupAcromegaly"
```

```
## [1] "acro.disease.normal <- results(acromegaly.cds.bmi, contrast=list(\"BMI.30.50..groupAcromegaly\", \"BMI.0.25..groupAcromegaly\"))\nsum(acro.disease.normal$padj<.05, na.rm=TRUE)\nacro.disease.overweight <- results(acromegaly.cds.bmi, contrast=list(\"BMI.25.30..groupAcromegaly\", \"BMI.25.30..groupControl\"))\nacro.disease.obese <- results(acromegaly.cds.bmi, contrast=list(\"BMI.30.50..groupAcromegaly\", \"BMI.30.50..groupControl\"))\n#acro.bmi.combined <- merge(acromegaly.results.bmi, acro.bmi.contrast, by.x=\"row.names\", by.y=\"row.names\")\nacro.bmi.combined <- cbind(acro.disease.normal, acro.disease.overweight)\ncolnames(acro.bmi.combined)[2:7]<- gsub(\"x\",\"AcrovsControl\", colnames(acro.bmi.combined)[2:7])\ncolnames(acro.bmi.combined)[8:13]<-gsub(\"y\",\"Obese_vs_Overweight\", colnames(acro.bmi.combined[8:13]))\nacro.bmi.combined <- acro.bmi.combined[order(acro.bmi.combined$padj.bmi, na.last=TRUE),]\n#acromegaly.results.bmi <- acromegaly.results.bmi[order(acromegaly.results.bmi$padj, na.last=TRUE),]\nwrite.csv(acro.bmi.combined, \"../data/processed/acromegaly_results_GRCh37.74-adjusting_bmi.csv\")"
```

![plot of chunk deseq-analysis adjusting for age](figure/deseq-analysis adjusting for age2.pdf) 

```
## [1] 102
```

```
## [1] "Intercept"                  "BMI_.30.50._vs_.25.30."    
## [3] "group_Cushing.s_vs_Control" "BMI.30.50..groupCushing.s"
```

![plot of chunk graphs](figure/graphs1.pdf) ![plot of chunk graphs](figure/graphs2.pdf) ![plot of chunk graphs](figure/graphs3.pdf) ![plot of chunk graphs](figure/graphs4.pdf) ![plot of chunk graphs](figure/graphs5.pdf) 
Annotation
-------------

This step annotates the data tables with the official gene symbols.



Session Information
-------------------

For the R session, the package versions were:

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
## [1] parallel  stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
##  [1] reshape2_1.4              ggplot2_1.0.0            
##  [3] biomaRt_2.20.0            DESeq2_1.4.5             
##  [5] RcppArmadillo_0.4.300.8.0 Rcpp_0.11.2              
##  [7] GenomicRanges_1.16.3      GenomeInfoDb_1.0.2       
##  [9] IRanges_1.22.9            BiocGenerics_0.10.0      
## [11] knitr_1.6                
## 
## loaded via a namespace (and not attached):
##  [1] annotate_1.42.0      AnnotationDbi_1.26.0 Biobase_2.24.0      
##  [4] colorspace_1.2-4     DBI_0.2-7            digest_0.6.4        
##  [7] evaluate_0.5.5       formatR_0.10         genefilter_1.46.1   
## [10] geneplotter_1.42.0   grid_3.1.0           gtable_0.1.2        
## [13] lattice_0.20-29      locfit_1.5-9.1       MASS_7.3-33         
## [16] munsell_0.4.2        plyr_1.8.1           proto_0.3-10        
## [19] RColorBrewer_1.0-5   RCurl_1.95-4.1       RSQLite_0.11.4      
## [22] scales_0.2.4         splines_3.1.0        stats4_3.1.0        
## [25] stringr_0.6.2        survival_2.37-7      tools_3.1.0         
## [28] XML_3.98-1.1         xtable_1.7-3         XVector_0.4.0
```
