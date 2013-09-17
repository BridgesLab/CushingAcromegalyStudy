GOSeq of DESeq Data for Acromegaly and Cushing's Patients
=============================================================


This analysis removes the lowest 40% expressed transcripts, and also removes the data from patient 29.  This script was most recently run on Tue Sep 17 09:41:09 2013.





To analyse these, we used the goseq package (<a href="">Young et al. 2010</a>), using the wallenius approximation to determine
significantly enriched GO (<a href="http://dx.doi.org/10.1038/75556">Botstein et al. 2000</a>) or KEGG (<a href="http://dx.doi.org/10.1093/nar/gkr988">Kanehisa et al. 2011</a>) terms.  

This analysis included the 343 significant cushing transcripts (78 genes) and the 535 significant acromegaly transcripts (157 genes).


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
For cushing, we found 5 significantly different GO terms for molecular function, 45 significantly different GO terms for biological processes and 10 significantly different KEGG pathways.

For acromegaly, we found 1 significantly different GO terms for molecular function, 13 significantly different GO terms for biological processes and 0 significantly different KEGG pathways.

### Cushing Significant Processes
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Tue Sep 17 09:42:34 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Biological Processes Enriched in Cushing Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 865 </TD> <TD> GO:0001927 </TD> <TD align="right"> 2 </TD> <TD align="right"> 3 </TD> <TD align="right"> 0.01921 </TD> <TD> exocyst assembly </TD> </TR>
  <TR> <TD align="right"> 866 </TD> <TD> GO:0001928 </TD> <TD align="right"> 2 </TD> <TD align="right"> 3 </TD> <TD align="right"> 0.01921 </TD> <TD> regulation of exocyst assembly </TD> </TR>
  <TR> <TD align="right"> 1383 </TD> <TD> GO:0002474 </TD> <TD align="right"> 7 </TD> <TD align="right"> 178 </TD> <TD align="right"> 0.00752 </TD> <TD> antigen processing and presentation of peptide antigen via MHC class I </TD> </TR>
  <TR> <TD align="right"> 1387 </TD> <TD> GO:0002478 </TD> <TD align="right"> 8 </TD> <TD align="right"> 298 </TD> <TD align="right"> 0.01761 </TD> <TD> antigen processing and presentation of exogenous peptide antigen </TD> </TR>
  <TR> <TD align="right"> 1388 </TD> <TD> GO:0002479 </TD> <TD align="right"> 7 </TD> <TD align="right"> 147 </TD> <TD align="right"> 0.00258 </TD> <TD> antigen processing and presentation of exogenous peptide antigen via MHC class I, TAP-dependent </TD> </TR>
  <TR> <TD align="right"> 1393 </TD> <TD> GO:0002480 </TD> <TD align="right"> 7 </TD> <TD align="right"> 45 </TD> <TD align="right"> 0.00001 </TD> <TD> antigen processing and presentation of exogenous peptide antigen via MHC class I, TAP-independent </TD> </TR>
  <TR> <TD align="right"> 1600 </TD> <TD> GO:0002682 </TD> <TD align="right"> 13 </TD> <TD align="right"> 893 </TD> <TD align="right"> 0.04408 </TD> <TD> regulation of immune system process </TD> </TR>
  <TR> <TD align="right"> 2494 </TD> <TD> GO:0006082 </TD> <TD align="right"> 14 </TD> <TD align="right"> 877 </TD> <TD align="right"> 0.01450 </TD> <TD> organic acid metabolic process </TD> </TR>
  <TR> <TD align="right"> 3936 </TD> <TD> GO:0006868 </TD> <TD align="right"> 2 </TD> <TD align="right"> 3 </TD> <TD align="right"> 0.02015 </TD> <TD> glutamine transport </TD> </TR>
  <TR> <TD align="right"> 4329 </TD> <TD> GO:0007166 </TD> <TD align="right"> 25 </TD> <TD align="right"> 1941 </TD> <TD align="right"> 0.00126 </TD> <TD> cell surface receptor signaling pathway </TD> </TR>
  <TR> <TD align="right"> 4332 </TD> <TD> GO:0007167 </TD> <TD align="right"> 12 </TD> <TD align="right"> 746 </TD> <TD align="right"> 0.04408 </TD> <TD> enzyme linked receptor protein signaling pathway </TD> </TR>
  <TR> <TD align="right"> 5729 </TD> <TD> GO:0009605 </TD> <TD align="right"> 14 </TD> <TD align="right"> 985 </TD> <TD align="right"> 0.04261 </TD> <TD> response to external stimulus </TD> </TR>
  <TR> <TD align="right"> 5776 </TD> <TD> GO:0009719 </TD> <TD align="right"> 14 </TD> <TD align="right"> 849 </TD> <TD align="right"> 0.01410 </TD> <TD> response to endogenous stimulus </TD> </TR>
  <TR> <TD align="right"> 5778 </TD> <TD> GO:0009725 </TD> <TD align="right"> 11 </TD> <TD align="right"> 501 </TD> <TD align="right"> 0.00912 </TD> <TD> response to hormone stimulus </TD> </TR>
  <TR> <TD align="right"> 5973 </TD> <TD> GO:0010033 </TD> <TD align="right"> 24 </TD> <TD align="right"> 1695 </TD> <TD align="right"> 0.00043 </TD> <TD> response to organic substance </TD> </TR>
  <TR> <TD align="right"> 6037 </TD> <TD> GO:0010243 </TD> <TD align="right"> 11 </TD> <TD align="right"> 466 </TD> <TD align="right"> 0.00626 </TD> <TD> response to organic nitrogen </TD> </TR>
  <TR> <TD align="right"> 7463 </TD> <TD> GO:0019221 </TD> <TD align="right"> 11 </TD> <TD align="right"> 393 </TD> <TD align="right"> 0.00126 </TD> <TD> cytokine-mediated signaling pathway </TD> </TR>
  <TR> <TD align="right"> 7875 </TD> <TD> GO:0019882 </TD> <TD align="right"> 8 </TD> <TD align="right"> 352 </TD> <TD align="right"> 0.04274 </TD> <TD> antigen processing and presentation </TD> </TR>
  <TR> <TD align="right"> 7879 </TD> <TD> GO:0019884 </TD> <TD align="right"> 8 </TD> <TD align="right"> 300 </TD> <TD align="right"> 0.01797 </TD> <TD> antigen processing and presentation of exogenous antigen </TD> </TR>
  <TR> <TD align="right"> 8256 </TD> <TD> GO:0022602 </TD> <TD align="right"> 4 </TD> <TD align="right"> 60 </TD> <TD align="right"> 0.04408 </TD> <TD> ovulation cycle process </TD> </TR>
  <TR> <TD align="right"> 9607 </TD> <TD> GO:0031668 </TD> <TD align="right"> 5 </TD> <TD align="right"> 113 </TD> <TD align="right"> 0.04408 </TD> <TD> cellular response to extracellular stimulus </TD> </TR>
  <TR> <TD align="right"> 9609 </TD> <TD> GO:0031670 </TD> <TD align="right"> 3 </TD> <TD align="right"> 18 </TD> <TD align="right"> 0.02210 </TD> <TD> cellular response to nutrient </TD> </TR>
  <TR> <TD align="right"> 10664 </TD> <TD> GO:0032787 </TD> <TD align="right"> 9 </TD> <TD align="right"> 355 </TD> <TD align="right"> 0.01410 </TD> <TD> monocarboxylic acid metabolic process </TD> </TR>
  <TR> <TD align="right"> 10827 </TD> <TD> GO:0032868 </TD> <TD align="right"> 7 </TD> <TD align="right"> 202 </TD> <TD align="right"> 0.01714 </TD> <TD> response to insulin stimulus </TD> </TR>
  <TR> <TD align="right"> 11406 </TD> <TD> GO:0033559 </TD> <TD align="right"> 4 </TD> <TD align="right"> 64 </TD> <TD align="right"> 0.04629 </TD> <TD> unsaturated fatty acid metabolic process </TD> </TR>
  <TR> <TD align="right"> 11582 </TD> <TD> GO:0034097 </TD> <TD align="right"> 14 </TD> <TD align="right"> 532 </TD> <TD align="right"> 0.00027 </TD> <TD> response to cytokine stimulus </TD> </TR>
  <TR> <TD align="right"> 11739 </TD> <TD> GO:0034340 </TD> <TD align="right"> 7 </TD> <TD align="right"> 103 </TD> <TD align="right"> 0.00043 </TD> <TD> response to type I interferon </TD> </TR>
  <TR> <TD align="right"> 11740 </TD> <TD> GO:0034341 </TD> <TD align="right"> 9 </TD> <TD align="right"> 193 </TD> <TD align="right"> 0.00035 </TD> <TD> response to interferon-gamma </TD> </TR>
  <TR> <TD align="right"> 12653 </TD> <TD> GO:0036109 </TD> <TD align="right"> 3 </TD> <TD align="right"> 10 </TD> <TD align="right"> 0.00648 </TD> <TD> alpha-linolenic acid metabolic process </TD> </TR>
  <TR> <TD align="right"> 13179 </TD> <TD> GO:0042221 </TD> <TD align="right"> 27 </TD> <TD align="right"> 2335 </TD> <TD align="right"> 0.00245 </TD> <TD> response to chemical stimulus </TD> </TR>
  <TR> <TD align="right"> 13778 </TD> <TD> GO:0042590 </TD> <TD align="right"> 7 </TD> <TD align="right"> 151 </TD> <TD align="right"> 0.00291 </TD> <TD> antigen processing and presentation of exogenous peptide antigen via MHC class I </TD> </TR>
  <TR> <TD align="right"> 14685 </TD> <TD> GO:0043434 </TD> <TD align="right"> 8 </TD> <TD align="right"> 278 </TD> <TD align="right"> 0.01714 </TD> <TD> response to peptide hormone stimulus </TD> </TR>
  <TR> <TD align="right"> 14686 </TD> <TD> GO:0043436 </TD> <TD align="right"> 14 </TD> <TD align="right"> 869 </TD> <TD align="right"> 0.01410 </TD> <TD> oxoacid metabolic process </TD> </TR>
  <TR> <TD align="right"> 15432 </TD> <TD> GO:0045087 </TD> <TD align="right"> 11 </TD> <TD align="right"> 571 </TD> <TD align="right"> 0.01761 </TD> <TD> innate immune response </TD> </TR>
  <TR> <TD align="right"> 18269 </TD> <TD> GO:0048002 </TD> <TD align="right"> 8 </TD> <TD align="right"> 322 </TD> <TD align="right"> 0.02420 </TD> <TD> antigen processing and presentation of peptide antigen </TD> </TR>
  <TR> <TD align="right"> 18724 </TD> <TD> GO:0048583 </TD> <TD align="right"> 23 </TD> <TD align="right"> 2114 </TD> <TD align="right"> 0.01921 </TD> <TD> regulation of response to stimulus </TD> </TR>
  <TR> <TD align="right"> 22104 </TD> <TD> GO:0060333 </TD> <TD align="right"> 9 </TD> <TD align="right"> 160 </TD> <TD align="right"> 0.00018 </TD> <TD> interferon-gamma-mediated signaling pathway </TD> </TR>
  <TR> <TD align="right"> 22124 </TD> <TD> GO:0060337 </TD> <TD align="right"> 7 </TD> <TD align="right"> 102 </TD> <TD align="right"> 0.00043 </TD> <TD> type I interferon-mediated signaling pathway </TD> </TR>
  <TR> <TD align="right"> 23379 </TD> <TD> GO:0070887 </TD> <TD align="right"> 20 </TD> <TD align="right"> 1541 </TD> <TD align="right"> 0.00860 </TD> <TD> cellular response to chemical stimulus </TD> </TR>
  <TR> <TD align="right"> 23566 </TD> <TD> GO:0071310 </TD> <TD align="right"> 19 </TD> <TD align="right"> 1255 </TD> <TD align="right"> 0.00245 </TD> <TD> cellular response to organic substance </TD> </TR>
  <TR> <TD align="right"> 23598 </TD> <TD> GO:0071345 </TD> <TD align="right"> 12 </TD> <TD align="right"> 462 </TD> <TD align="right"> 0.00107 </TD> <TD> cellular response to cytokine stimulus </TD> </TR>
  <TR> <TD align="right"> 23599 </TD> <TD> GO:0071346 </TD> <TD align="right"> 9 </TD> <TD align="right"> 179 </TD> <TD align="right"> 0.00027 </TD> <TD> cellular response to interferon-gamma </TD> </TR>
  <TR> <TD align="right"> 23609 </TD> <TD> GO:0071357 </TD> <TD align="right"> 7 </TD> <TD align="right"> 102 </TD> <TD align="right"> 0.00043 </TD> <TD> cellular response to type I interferon </TD> </TR>
  <TR> <TD align="right"> 26752 </TD> <TD> GO:1901652 </TD> <TD align="right"> 8 </TD> <TD align="right"> 287 </TD> <TD align="right"> 0.01884 </TD> <TD> response to peptide </TD> </TR>
  <TR> <TD align="right"> 26852 </TD> <TD> GO:1901698 </TD> <TD align="right"> 11 </TD> <TD align="right"> 497 </TD> <TD align="right"> 0.00912 </TD> <TD> response to nitrogen compound </TD> </TR>
   </TABLE>
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Tue Sep 17 09:42:34 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Molecular Functions Enriched in Cushing Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 3370 </TD> <TD> GO:0004459 </TD> <TD align="right"> 2 </TD> <TD align="right"> 3 </TD> <TD align="right"> 0.04571 </TD> <TD> L-lactate dehydrogenase activity </TD> </TR>
  <TR> <TD align="right"> 5157 </TD> <TD> GO:0004768 </TD> <TD align="right"> 2 </TD> <TD align="right"> 3 </TD> <TD align="right"> 0.04571 </TD> <TD> stearoyl-CoA 9-desaturase activity </TD> </TR>
  <TR> <TD align="right"> 8350 </TD> <TD> GO:0016215 </TD> <TD align="right"> 2 </TD> <TD align="right"> 3 </TD> <TD align="right"> 0.04571 </TD> <TD> acyl-CoA desaturase activity </TD> </TR>
  <TR> <TD align="right"> 8630 </TD> <TD> GO:0016717 </TD> <TD align="right"> 3 </TD> <TD align="right"> 6 </TD> <TD align="right"> 0.00338 </TD> <TD> oxidoreductase activity, acting on paired donors, with oxidation of a pair of donors resulting in the reduction of molecular oxygen to two molecules of water </TD> </TR>
  <TR> <TD align="right"> 9723 </TD> <TD> GO:0032393 </TD> <TD align="right"> 7 </TD> <TD align="right"> 59 </TD> <TD align="right"> 0.00002 </TD> <TD> MHC class I receptor activity </TD> </TR>
   </TABLE>
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Tue Sep 17 09:42:34 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> KEGG Pathways Enriched in Cushing Patientes </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> path_name </TH>  </TR>
  <TR> <TD align="right"> 84 </TD> <TD> 01040 </TD> <TD align="right"> 3 </TD> <TD align="right"> 21 </TD> <TD align="right"> 0.00245 </TD> <TD> Biosynthesis of unsaturated fatty acids </TD> </TR>
  <TR> <TD align="right"> 120 </TD> <TD> 04144 </TD> <TD align="right"> 8 </TD> <TD align="right"> 235 </TD> <TD align="right"> 0.00035 </TD> <TD> Endocytosis </TD> </TR>
  <TR> <TD align="right"> 121 </TD> <TD> 04145 </TD> <TD align="right"> 8 </TD> <TD align="right"> 266 </TD> <TD align="right"> 0.00058 </TD> <TD> Phagosome </TD> </TR>
  <TR> <TD align="right"> 137 </TD> <TD> 04514 </TD> <TD align="right"> 9 </TD> <TD align="right"> 213 </TD> <TD align="right"> 0.00006 </TD> <TD> Cell adhesion molecules (CAMs) </TD> </TR>
  <TR> <TD align="right"> 142 </TD> <TD> 04612 </TD> <TD align="right"> 8 </TD> <TD align="right"> 188 </TD> <TD align="right"> 0.00006 </TD> <TD> Antigen processing and presentation </TD> </TR>
  <TR> <TD align="right"> 171 </TD> <TD> 04940 </TD> <TD align="right"> 7 </TD> <TD align="right"> 130 </TD> <TD align="right"> 0.00006 </TD> <TD> Type I diabetes mellitus </TD> </TR>
  <TR> <TD align="right"> 219 </TD> <TD> 05320 </TD> <TD align="right"> 7 </TD> <TD align="right"> 131 </TD> <TD align="right"> 0.00006 </TD> <TD> Autoimmune thyroid disease </TD> </TR>
  <TR> <TD align="right"> 222 </TD> <TD> 05330 </TD> <TD align="right"> 7 </TD> <TD align="right"> 128 </TD> <TD align="right"> 0.00006 </TD> <TD> Allograft rejection </TD> </TR>
  <TR> <TD align="right"> 223 </TD> <TD> 05332 </TD> <TD align="right"> 7 </TD> <TD align="right"> 128 </TD> <TD align="right"> 0.00006 </TD> <TD> Graft-versus-host disease </TD> </TR>
  <TR> <TD align="right"> 228 </TD> <TD> 05416 </TD> <TD align="right"> 7 </TD> <TD align="right"> 164 </TD> <TD align="right"> 0.00024 </TD> <TD> Viral myocarditis </TD> </TR>
   </TABLE>


### Acromegaly Significant Processes
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Tue Sep 17 09:42:34 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Biological Processes Enriched in Acromegaly Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 3570 </TD> <TD> GO:0006694 </TD> <TD align="right"> 7 </TD> <TD align="right"> 115 </TD> <TD align="right"> 0.04579 </TD> <TD> steroid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 3857 </TD> <TD> GO:0006796 </TD> <TD align="right"> 35 </TD> <TD align="right"> 2193 </TD> <TD align="right"> 0.04843 </TD> <TD> phosphate-containing compound metabolic process </TD> </TR>
  <TR> <TD align="right"> 4566 </TD> <TD> GO:0007275 </TD> <TD align="right"> 45 </TD> <TD align="right"> 3044 </TD> <TD align="right"> 0.04579 </TD> <TD> multicellular organismal development </TD> </TR>
  <TR> <TD align="right"> 4812 </TD> <TD> GO:0008202 </TD> <TD align="right"> 10 </TD> <TD align="right"> 204 </TD> <TD align="right"> 0.01160 </TD> <TD> steroid metabolic process </TD> </TR>
  <TR> <TD align="right"> 4967 </TD> <TD> GO:0008610 </TD> <TD align="right"> 14 </TD> <TD align="right"> 502 </TD> <TD align="right"> 0.04579 </TD> <TD> lipid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 5414 </TD> <TD> GO:0009225 </TD> <TD align="right"> 4 </TD> <TD align="right"> 28 </TD> <TD align="right"> 0.04819 </TD> <TD> nucleotide-sugar metabolic process </TD> </TR>
  <TR> <TD align="right"> 7459 </TD> <TD> GO:0019218 </TD> <TD align="right"> 5 </TD> <TD align="right"> 49 </TD> <TD align="right"> 0.04579 </TD> <TD> regulation of steroid metabolic process </TD> </TR>
  <TR> <TD align="right"> 11951 </TD> <TD> GO:0034754 </TD> <TD align="right"> 7 </TD> <TD align="right"> 72 </TD> <TD align="right"> 0.00654 </TD> <TD> cellular hormone metabolic process </TD> </TR>
  <TR> <TD align="right"> 13541 </TD> <TD> GO:0042445 </TD> <TD align="right"> 9 </TD> <TD align="right"> 115 </TD> <TD align="right"> 0.00373 </TD> <TD> hormone metabolic process </TD> </TR>
  <TR> <TD align="right"> 15113 </TD> <TD> GO:0044281 </TD> <TD align="right"> 35 </TD> <TD align="right"> 2216 </TD> <TD align="right"> 0.04579 </TD> <TD> small molecule metabolic process </TD> </TR>
  <TR> <TD align="right"> 15115 </TD> <TD> GO:0044283 </TD> <TD align="right"> 12 </TD> <TD align="right"> 376 </TD> <TD align="right"> 0.04579 </TD> <TD> small molecule biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 15194 </TD> <TD> GO:0044711 </TD> <TD align="right"> 12 </TD> <TD align="right"> 381 </TD> <TD align="right"> 0.04579 </TD> <TD> single-organism biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 19110 </TD> <TD> GO:0050673 </TD> <TD align="right"> 10 </TD> <TD align="right"> 182 </TD> <TD align="right"> 0.01160 </TD> <TD> epithelial cell proliferation </TD> </TR>
   </TABLE>
<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Tue Sep 17 09:42:34 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Molecular Functions Enriched in Acromegaly Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 8630 </TD> <TD> GO:0016717 </TD> <TD align="right"> 3 </TD> <TD align="right"> 6 </TD> <TD align="right"> 0.03698 </TD> <TD> oxidoreductase activity, acting on paired donors, with oxidation of a pair of donors resulting in the reduction of molecular oxygen to two molecules of water </TD> </TR>
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

