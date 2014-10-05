Comparason of Data from our Study with GEO Deposited Data
=============================================================


This script was most recently run on Sun Oct  5 08:09:57 2014.  



```
## Warning: package 'knitcitations' was built under R version 3.1.1
```

Huo et al Dataset
---------------------

The authors in Huo (2006) treated 3T3-F442A adipocytes either with nothing or with GH for 0.5, 4 or 48h.  These data are in the dataset GSE2120.  I generated R code using GEO2R comparing the control and growth hormone treated samples at 48h.



### Upregulated Genes

Of the 290 significantly upregulated genes on the chip, 129 had identifiable human homologs, of which there were 155 probes.  These genes were on average **upregulated** to 1.0977 of their original control levels.  The p-value that these genes are upregulated is 0.0267.  Of these 155 mouse genes that had probes, 79 were upregulated.  Specifically, these genes were GGCT, FMO1, ABHD5, ELOVL5, IGF1, GPM6B, PTGER3, PKN2, ME1, HLTF, CAPN6, ACHE, SRPX, STAG2, MYEF2, CCNE1, COL1A1, ALDOC, GAB1, AMBRA1, BMP5, CCNG1, CISH, PRKD3, ORC2, ATF2, SCP2, SOCS2, EPHX2, ITPR2, PLP1, CHPF, FGL2, GNAI1, GFAP, STAT4, AKT1, ZMYM4, IGFBP3, DIAPH2, TCF7L2, FADS1, SIDT2, ADRA2A, PTPN14, AK4, B3GALNT2, SERPINI1, CYB5A, MAPRE2, UGP2, TOR1AIP2, ALK, KCNK3, MLLT3, CALB2, CES3, IDH2, KCNA4, DRG1, PRR5, TCEA1, ADRB3, PPP3R1, PEG10, WDR92, EID1

### Downregulated Genes

Of the 128 significantly downregulated genes, 65 had identifiable human homologs on that array chip, of which there were 75 probes.  These genes were on average **downregulated** to 0.9031 of their original control levels.  The p-value that these genes are downregulated is 0.0092.  Of these 75 mouse genes that had probes, 27 were downregulated.  Specifically, these genes were ABCC2, NTN1, TCF3, PTPN18, WNT11, HSF4, STX4, IKBKB, LTBR, ZFP36, PSME3, GOLM1, RDH5, RTN1, GPC3, CDKN2B, DCK, STAT6, SLC3A2, FOS, JUNB, GAS6, MAFF, RASA3, APOD, RYR1, TCEA3.

### Enrichment Testing
We found 418 significantly different genes in the acromegaly study.  Our re-analysis of the growth hormone study found 560 differentially expressed genes.  That corresponds to 6.0929% of the genes are different.  Out of those genes, 448 map to human homologs.  Out of the transcripts mapped to those genes, 23 out of 447 (or 5.1454%)` were significantly different in the acromegaly data, so there was no enrichment.

Done the other way, we found 418 significantly different acromegaly genes out of a total of 22810 genes tested (or 1.8325%).  Out of these 418 genes, 194 have mouse homologs, and 228 probes in this dataset.  From these probes, 26 were significant (or 10.3537%).  Therefore the genes from the acromegaly dataset are enriched in the growth hormone treated dataset (p=6.1867 &times; 10<sup>-5</sup>).  The genes which were significant in both datasets were Cish, Pkd2, Itpr2, Fmo1, Phldb2, Wnt11, Ccng1, Fads1, Elovl5, Sept4, Hmgcs1, Wisp2, Ggct, Igfbp3, Cxcl1, Igf1, Scd2, Scp2, Ptger3, Capn6, Fasn, Socs2, Klf4

References
-----------

```r
bibliography()
```

[1] J. S. Huo. "Profiles of Growth Hormone (GH)-regulated Genes
Reveal Time-dependent Responses and Identify a Mechanism for
Regulation of Activating Transcription Factor 3 By GH". In:
_Journal of Biological Chemistry_ 281.7 (Jan. 2006), pp.
4132-4141. DOI: 10.1074/jbc.m508492200. <URL:
http://dx.doi.org/10.1074/jbc.M508492200>.

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
## [1] biomaRt_2.20.0      limma_3.20.9        GEOquery_2.30.1    
## [4] Biobase_2.24.0      BiocGenerics_0.10.0 knitcitations_1.0-1
## [7] devtools_1.5        knitr_1.6          
## 
## loaded via a namespace (and not attached):
##  [1] AnnotationDbi_1.26.0 bibtex_0.3-6         DBI_0.3.0           
##  [4] digest_0.6.4         evaluate_0.5.5       formatR_1.0         
##  [7] GenomeInfoDb_1.0.2   httr_0.5             IRanges_1.22.10     
## [10] lubridate_1.3.3      memoise_0.2.1        plyr_1.8.1          
## [13] Rcpp_0.11.2          RCurl_1.95-4.3       RefManageR_0.8.34   
## [16] RJSONIO_1.3-0        RSQLite_0.11.4       stats4_3.1.0        
## [19] stringr_0.6.2        tools_3.1.0          whisker_0.3-2       
## [22] XML_3.98-1.1
```
