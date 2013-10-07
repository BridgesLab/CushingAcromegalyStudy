GOSeq of DESeq Data for Acromegaly and Cushing's Patients
=============================================================


This analysis removes the lowest 40% expressed transcripts, and also removes the data from patient 29.  This script was most recently run on Thu Oct  3 11:56:14 2013.





To analyse these, we used the goseq package (<a href="">Young et al. 2010</a>), using the wallenius approximation to determine
significantly enriched GO (<a href="http://dx.doi.org/10.1038/75556">Botstein et al. 2000</a>) or KEGG (<a href="http://dx.doi.org/10.1093/nar/gkr988">Kanehisa et al. 2011</a>) terms.  

This analysis included the 24 significant cushing transcripts (24 genes) and the 117 significant acromegaly transcripts (117 genes).


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
For cushing, we found 2 significantly different GO terms for molecular function, 5 significantly different GO terms for biological processes and 0 significantly different KEGG pathways.

For acromegaly, we found 0 significantly different GO terms for molecular function, 5 significantly different GO terms for biological processes and 1 significantly different KEGG pathways.

### Cushing Significant Processes
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Thu Oct  3 11:57:52 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Biological Processes Enriched in Cushing Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 10050 </TD> <TD> GO:0031670 </TD> <TD align="right"> 3 </TD> <TD align="right"> 21 </TD> <TD align="right"> 0.00814 </TD> <TD> cellular response to nutrient </TD> </TR>
  <TR> <TD align="right"> 4119 </TD> <TD> GO:0006865 </TD> <TD align="right"> 4 </TD> <TD align="right"> 114 </TD> <TD align="right"> 0.00965 </TD> <TD> amino acid transport </TD> </TR>
  <TR> <TD align="right"> 4120 </TD> <TD> GO:0006868 </TD> <TD align="right"> 2 </TD> <TD align="right"> 3 </TD> <TD align="right"> 0.00965 </TD> <TD> glutamine transport </TD> </TR>
  <TR> <TD align="right"> 7062 </TD> <TD> GO:0015849 </TD> <TD align="right"> 4 </TD> <TD align="right"> 197 </TD> <TD align="right"> 0.04500 </TD> <TD> organic acid transport </TD> </TR>
  <TR> <TD align="right"> 19004 </TD> <TD> GO:0046942 </TD> <TD align="right"> 4 </TD> <TD align="right"> 197 </TD> <TD align="right"> 0.04500 </TD> <TD> carboxylic acid transport </TD> </TR>
   </TABLE>
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Thu Oct  3 11:57:52 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Molecular Functions Enriched in Cushing Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 8333 </TD> <TD> GO:0015171 </TD> <TD align="right"> 3 </TD> <TD align="right"> 53 </TD> <TD align="right"> 0.04451 </TD> <TD> amino acid transmembrane transporter activity </TD> </TR>
  <TR> <TD align="right"> 9344 </TD> <TD> GO:0017153 </TD> <TD align="right"> 2 </TD> <TD align="right"> 8 </TD> <TD align="right"> 0.04451 </TD> <TD> sodium:dicarboxylate symporter activity </TD> </TR>
   </TABLE>

```
## Warning: data length exceeds size of matrix
```

<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Thu Oct  3 11:57:52 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> KEGG Pathways Enriched in Cushing Patientes </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> path_name </TH>  </TR>
  </TABLE>


### Acromegaly Significant Processes
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Thu Oct  3 11:57:52 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Biological Processes Enriched in Acromegaly Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 14190 </TD> <TD> GO:0042445 </TD> <TD align="right"> 7 </TD> <TD align="right"> 147 </TD> <TD align="right"> 0.02610 </TD> <TD> hormone metabolic process </TD> </TR>
  <TR> <TD align="right"> 3748 </TD> <TD> GO:0006694 </TD> <TD align="right"> 6 </TD> <TD align="right"> 128 </TD> <TD align="right"> 0.04725 </TD> <TD> steroid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 3783 </TD> <TD> GO:0006704 </TD> <TD align="right"> 3 </TD> <TD align="right"> 13 </TD> <TD align="right"> 0.04725 </TD> <TD> glucocorticoid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 5203 </TD> <TD> GO:0008610 </TD> <TD align="right"> 11 </TD> <TD align="right"> 540 </TD> <TD align="right"> 0.04725 </TD> <TD> lipid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 12513 </TD> <TD> GO:0034754 </TD> <TD align="right"> 5 </TD> <TD align="right"> 86 </TD> <TD align="right"> 0.04725 </TD> <TD> cellular hormone metabolic process </TD> </TR>
   </TABLE>

```
## Warning: data length exceeds size of matrix
```

<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Thu Oct  3 11:57:52 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Molecular Functions Enriched in Acromegaly Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  </TABLE>


Bibiography
------------

- David Botstein, J. Michael Cherry, Michael Ashburner, Catherine A. Ball, Judith A. Blake, Heather Butler, Allan P. Davis, Kara Dolinski, Selina S. Dwight, Janan T. Eppig, Midori A. Harris, David P. Hill, Laurie Issel-Tarver, Andrew Kasarskis, Suzanna Lewis, John C. Matese, Joel E. Richardson, Martin Ringwald, Gerald M. Rubin, Gavin Sherlock,   (2000) Unknown.  <em>Nature Genetics</em>  <strong>25</strong>  25-29  <a href="http://dx.doi.org/10.1038/75556">10.1038/75556</a>
- Matthew Young, Matthew Wakefield, Gordon Smyth, Alicia Oshlack,   (2010) Gene ontology analysis for RNA-seq: accounting for selection bias.  <em>Genome Biology</em>  <strong>11</strong>  R14-NA
- M. Kanehisa, S. Goto, Y. Sato, M. Furumichi, M. Tanabe,   (2011) Kegg For Integration And Interpretation of Large-Scale Molecular Data Sets.  <em>Nucleic Acids Research</em>  <strong>40</strong>  D109-D114  <a href="http://dx.doi.org/10.1093/nar/gkr988">10.1093/nar/gkr988</a>


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

