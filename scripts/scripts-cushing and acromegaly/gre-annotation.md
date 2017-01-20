# Annotation of the GRE Dataset
Innocence Harvey and Dave Bridges  
February 23, 2015  



This data is from the GR CHIP-seq paper by Reddy \textit{et al.}.  They only provided peaks with a p-value cutoff of < 1.0 * 10-10.



The dataset from was downloaded as ../data/raw/Genomic determination of the GC response-Dataset1.txt.



The peaks were annotated by Nearest Start codon using ChIPpeakAnno to hg18.  The distrubution of peak to nearest start is shown below below.  The distributions of significantly differentially occupied sites to all occupied sites was not different by Two-sample Kolmogorov-Smirnov test (p=0.9709498).

We annotated 16083 sites from 4774 different genes.  8328 sites from 2976 different genes were differentially occupied in the presence of dexamethasone.  The annotated data is written out to the files ../data/processed/Annotated GR Peaks.csv and ../data/processed/Annotated GR Peaks - Significantly Changed.csv.

![](figures/start-site-distance-1.png) 

# Session Information

```
## R version 3.1.2 (2014-10-31)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] grid      parallel  stats     graphics  grDevices utils     datasets 
## [8] methods   base     
## 
## other attached packages:
##  [1] ChIPpeakAnno_2.14.1  AnnotationDbi_1.26.1 Biobase_2.24.0      
##  [4] RSQLite_1.0.0        DBI_0.3.1            Biostrings_2.32.1   
##  [7] XVector_0.4.0        biomaRt_2.20.0       VennDiagram_1.6.9   
## [10] GenomicRanges_1.16.4 GenomeInfoDb_1.0.2   IRanges_1.22.10     
## [13] BiocGenerics_0.10.0  knitr_1.9           
## 
## loaded via a namespace (and not attached):
##  [1] base64enc_0.1-2         BatchJobs_1.5          
##  [3] BBmisc_1.9              BiocParallel_0.6.1     
##  [5] bitops_1.0-6            brew_1.0-6             
##  [7] BSgenome_1.32.0         checkmate_1.5.1        
##  [9] codetools_0.2-10        digest_0.6.8           
## [11] evaluate_0.5.5          fail_1.2               
## [13] foreach_1.4.2           formatR_1.0            
## [15] GenomicAlignments_1.0.6 GenomicFeatures_1.16.3 
## [17] GO.db_2.14.0            htmltools_0.2.6        
## [19] iterators_1.0.7         limma_3.20.9           
## [21] MASS_7.3-37             multtest_2.20.0        
## [23] Rcpp_0.11.4             RCurl_1.95-4.5         
## [25] rmarkdown_0.5.1         Rsamtools_1.16.1       
## [27] rtracklayer_1.24.2      sendmailR_1.2-1        
## [29] splines_3.1.2           stats4_3.1.2           
## [31] stringr_0.6.2           survival_2.37-7        
## [33] tools_3.1.2             XML_3.98-1.1           
## [35] yaml_2.1.13             zlibbioc_1.10.0
```
