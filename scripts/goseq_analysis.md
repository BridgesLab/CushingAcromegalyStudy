GOSeq of DESeq Data for Acromegaly and Cushing's Patients
=============================================================


This analysis removes the lowest 40% expressed transcripts.  This script was most recently run on Sun Aug 18 14:54:40 2013.





To analyse these, we used the goseq package (<a href="">Young et al. 2010</a>), using the wallenius approximation to determine
significantly enriched GO (<a href="http://dx.doi.org/10.1038/75556">Botstein et al. 2000</a>) or KEGG (<a href="http://dx.doi.org/10.1093/nar/gkr988">Kanehisa et al. 2011</a>) terms.  Results were annotated using (<a href=""></a>) and (<a href=""></a>)

This analysis included the 189 significant cushing transcripts (58 genes) and the 721 significant acromegaly transcripts (199 genes).


```
## Warning: the matrix is either rank-deficient or indefinite
```

![plot of chunk goseq-analysis](figure/goseq-analysis1.png) 

```
## Warning: the matrix is either rank-deficient or indefinite
```

![plot of chunk goseq-analysis](figure/goseq-analysis2.png) 


Significantly different terms and pathways
----------------------------------------------
For cushing, we found 0 significantly different GO terms for molecular function, 9 significantly different GO terms for biological processes and 0 significantly different KEGG pathways.

For acromegaly, we found 0 significantly different GO terms for molecular function, 4 significantly different GO terms for biological processes and 0 significantly different KEGG pathways.

### Cushing Significant Processes
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Sun Aug 18 14:56:03 2013 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 865 </TD> <TD> GO:0001927 </TD> <TD align="right">   2 </TD> <TD align="right">   3 </TD> <TD align="right"> 0.05 </TD> <TD> exocyst assembly </TD> </TR>
  <TR> <TD align="right"> 866 </TD> <TD> GO:0001928 </TD> <TD align="right">   2 </TD> <TD align="right">   3 </TD> <TD align="right"> 0.05 </TD> <TD> regulation of exocyst assembly </TD> </TR>
  <TR> <TD align="right"> 3934 </TD> <TD> GO:0006868 </TD> <TD align="right">   2 </TD> <TD align="right">   3 </TD> <TD align="right"> 0.05 </TD> <TD> glutamine transport </TD> </TR>
  <TR> <TD align="right"> 4330 </TD> <TD> GO:0007167 </TD> <TD align="right">  11 </TD> <TD align="right"> 745 </TD> <TD align="right"> 0.05 </TD> <TD> enzyme linked receptor protein signaling pathway </TD> </TR>
  <TR> <TD align="right"> 5774 </TD> <TD> GO:0009719 </TD> <TD align="right">  12 </TD> <TD align="right"> 848 </TD> <TD align="right"> 0.05 </TD> <TD> response to endogenous stimulus </TD> </TR>
  <TR> <TD align="right"> 5776 </TD> <TD> GO:0009725 </TD> <TD align="right">   9 </TD> <TD align="right"> 501 </TD> <TD align="right"> 0.05 </TD> <TD> response to hormone stimulus </TD> </TR>
  <TR> <TD align="right"> 6035 </TD> <TD> GO:0010243 </TD> <TD align="right">   9 </TD> <TD align="right"> 466 </TD> <TD align="right"> 0.05 </TD> <TD> response to organic nitrogen </TD> </TR>
  <TR> <TD align="right"> 9607 </TD> <TD> GO:0031670 </TD> <TD align="right">   3 </TD> <TD align="right">  18 </TD> <TD align="right"> 0.05 </TD> <TD> cellular response to nutrient </TD> </TR>
  <TR> <TD align="right"> 26845 </TD> <TD> GO:1901698 </TD> <TD align="right">   9 </TD> <TD align="right"> 497 </TD> <TD align="right"> 0.05 </TD> <TD> response to nitrogen compound </TD> </TR>
   </TABLE>


### Acromegaly Significant Processes
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Sun Aug 18 14:56:03 2013 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 4564 </TD> <TD> GO:0007275 </TD> <TD align="right">  56 </TD> <TD align="right"> 3039 </TD> <TD align="right"> 0.04 </TD> <TD> multicellular organismal development </TD> </TR>
  <TR> <TD align="right"> 4965 </TD> <TD> GO:0008610 </TD> <TD align="right">  17 </TD> <TD align="right"> 502 </TD> <TD align="right"> 0.04 </TD> <TD> lipid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 11949 </TD> <TD> GO:0034754 </TD> <TD align="right">   7 </TD> <TD align="right">  72 </TD> <TD align="right"> 0.03 </TD> <TD> cellular hormone metabolic process </TD> </TR>
  <TR> <TD align="right"> 13539 </TD> <TD> GO:0042445 </TD> <TD align="right">   9 </TD> <TD align="right"> 115 </TD> <TD align="right"> 0.03 </TD> <TD> hormone metabolic process </TD> </TR>
   </TABLE>


Bibiography
------------

- David Botstein, J. Michael Cherry, Michael Ashburner, Catherine A. Ball, Judith A. Blake, Heather Butler, Allan P. Davis, Kara Dolinski, Selina S. Dwight, Janan T. Eppig, Midori A. Harris, David P. Hill, Laurie Issel-Tarver, Andrew Kasarskis, Suzanna Lewis, John C. Matese, Joel E. Richardson, Martin Ringwald, Gerald M. Rubin, Gavin Sherlock,   (2000) Unknown.  <em>Nature Genetics</em>  <strong>25</strong>  25-29  <a href="http://dx.doi.org/10.1038/75556">10.1038/75556</a>
- Marc Carlson,  GO.db: A set of annotation maps describing the entire Gene Ontology.
- Matthew Young, Matthew Wakefield, Gordon Smyth, Alicia Oshlack,   (2010) Gene ontology analysis for RNA-seq: accounting for selection bias.  <em>Genome Biology</em>  <strong>11</strong>  R14-NA
- M. Kanehisa, S. Goto, Y. Sato, M. Furumichi, M. Tanabe,   (2011) Kegg For Integration And Interpretation of Large-Scale Molecular Data Sets.  <em>Nucleic Acids Research</em>  <strong>40</strong>  D109-D114  <a href="http://dx.doi.org/10.1093/nar/gkr988">10.1093/nar/gkr988</a>
- Marc Carlson,  KEGG.db: A set of annotation maps for KEGG.


Session Information
-------------------

For the R session, the package versions were:

```r
sessionInfo()
```

```
## R version 3.0.1 (2013-05-16)
## Platform: x86_64-apple-darwin10.8.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] parallel  stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
##  [1] xtable_1.7-1            org.Hs.eg.db_2.9.0     
##  [3] KEGG.db_2.9.1           GO.db_2.9.0            
##  [5] RSQLite_0.11.4          DBI_0.2-7              
##  [7] AnnotationDbi_1.22.6    Biobase_2.20.1         
##  [9] BiocGenerics_0.6.0      goseq_1.12.0           
## [11] geneLenDataBase_0.99.11 BiasedUrn_1.05         
## [13] knitcitations_0.5-0     bibtex_0.3-6           
## [15] knitr_1.4              
## 
## loaded via a namespace (and not attached):
##  [1] biomaRt_2.16.0         Biostrings_2.28.0      bitops_1.0-5          
##  [4] BSgenome_1.28.0        digest_0.6.3           evaluate_0.4.7        
##  [7] formatR_0.9            GenomicFeatures_1.12.3 GenomicRanges_1.12.4  
## [10] grid_3.0.1             httr_0.2               IRanges_1.18.2        
## [13] lattice_0.20-15        Matrix_1.0-12          mgcv_1.7-24           
## [16] nlme_3.1-110           RCurl_1.95-4.1         Rsamtools_1.12.3      
## [19] rtracklayer_1.20.4     stats4_3.0.1           stringr_0.6.2         
## [22] tools_3.0.1            XML_3.95-0.2           zlibbioc_1.6.0
```

