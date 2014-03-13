Comparason of Data from our Study with GEO Deposited Data
=============================================================


This script was most recently run on Tue Mar 11 00:23:17 2014.  





Huo et al Dataset
---------------------

The authors in <a href="http://dx.doi.org/10.1074/jbc.M508492200">Huo (2006)</a> treated 3T3-F442A adipocytes either with nothing or with HG for 0.5, 4 or 48h.  These data are in the dataset GSE2120.  I generated R code using GEO2R comparing the control and growth hormone treated samples at 48h.




### Upregulated Genes

Of the 371 significantly upregulated genes on the chip, 171 had identifiable human homologs, of which there were 206 probes.  These genes were on average **upregulated** to 1.08 of their original control levels.  The p-value that these genes are upregulated is 0.024.  Of these 206 mouse genes that had probes, 102 were upregulated.  Specifically, these genes were GGCT, FMO1, ABHD5, ELOVL5, IGF1, GPM6B, PTGER3, PKN2, ME1, HLTF, PLD1, CAPN6, ACHE, SRPX, STAG2, MYEF2, CCNE1, COL1A1, ALDOC, GAB1, AMBRA1, CD81, BMP5, HMGCR, CCNG1, PRLR, CISH, PRKD3, ORC2, ATF2, SCP2, RRAGC, SOCS2, EPHX2, ITPR2, PLP1, CHPF, GDF5, FGL2, GNAI1, GFAP, GRSF1, ERCC5, SRPK2, STAT4, AKT1, GOLGA4, PTPRG, ZMYM4, IGFBP3, DIAPH2, STOM, TCF7L2, FADS1, SIDT2, ADRA2A, PTPN14, AK4, B3GALNT2, SERPINI1, ABCA1, CYB5A, MAPRE2, UGP2, TOR1AIP2, HAS2, ALK, KCNK3, MLLT3, PTEN, CALB2, CES3, RHOD, C1QTNF1, IDH2, KCNA4, DRG1, PRR5, GABRD, TCEA1, ADRB3, PPP3R1, PEG10, WDR92, EID1, BIVM-ERCC5

### Downregulated Genes

Of the 189 significantly downregulated genes, 95 had identifiable human homologs on that array chip, of which there were 106 probes.  These genes were on average **downregulated** to 0.9569 of their original control levels.  The p-value that these genes are downregulated is 0.0944.  Of these 106 mouse genes that had probes, 46 were downregulated.  Specifically, these genes were ABCC2, U2AF2, NTN1, TCF3, PTPN18, WNT11, SH3BP2, TBC1D10A, LGALS1, HSF4, STX4, IKBKB, TRMT1, CCL8, BST1, LTBR, CTGF, ATP8A1, TUBA4A, ZFP36, PSME3, GOLM1, RDH5, SLC7A1, RTN1, MFGE8, IMPA2, ADAM15, GPC3, CDKN2B, DCK, NTAN1, GALNT10, MAPK7, STAT6, SLC3A2, SHOX2, FOS, JUNB, GAS6, MAFF, RASA3, APOD, RYR1, TCEA3, DBNDD2, RP1-130H16.18.

### Enrichment Testing
We found 560 significantly different genes in the acromegaly study.  Our re-analysis of the growth hormone study found 560 differentially expressed genes.  That corresponds to 6.0929% of the genes are different.  Out of those genes, 448 map to human homologs.  Out of the transcripts mapped to those genes, 30 out of 447 (or 6.7114%)` were significantly different in the acromegaly data, so there was no enrichment.

Done the other way, we found 560 significantly different acromegaly genes out of a total of 22810 genes tested (or 2.4551%).  Out of these 560 genes, 266 have mouse homologs, and 310 probes in this dataset.  From these probes, 32 were significant (or 9.2894%).  Therefore the genes from the acromegaly dataset are enriched in the growth hormone treated dataset (p=7.8615 &times; 10<sup>-5</sup>).  The genes which were significant in both datasets were Cish, Pkd2, Itpr2, Pld1, Fmo1, Phldb2, Wnt11, Bst1, Ccng1, Rpa3, Fads1, Elovl5, Mpdz, Prlr, Sept4, Hmgcs1, Wisp2, Pten, Ggct, Igfbp3, Igf1, Scd2, Scp2, Ptger3, Capn6, Fasn, Gdf5, Socs2, Klf4

References
-----------

```r
bibliography()
```


- J. S. Huo,   (2006) Profiles of Growth Hormone (gh)-Regulated Genes Reveal Time-Dependent Responses And Identify A Mechanism For Regulation of Activating Transcription Factor 3 by gh.  *Journal of Biological Chemistry*  **281**  4132-4141  [10.1074/jbc.M508492200](http://dx.doi.org/10.1074/jbc.M508492200)


Session Information
-------------------

For the R session, the package versions were:

```r
sessionInfo()
```

```
## R version 3.0.2 (2013-09-25)
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
## [1] biomaRt_2.18.0      limma_3.18.13       GEOquery_2.28.0    
## [4] Biobase_2.22.0      BiocGenerics_0.8.0  knitcitations_0.5-0
## [7] bibtex_0.3-6        devtools_1.4.1      knitr_1.5          
## 
## loaded via a namespace (and not attached):
##  [1] digest_0.6.4   evaluate_0.5.1 formatR_0.10   httr_0.2      
##  [5] memoise_0.1    RCurl_1.95-4.1 stringr_0.6.2  tools_3.0.2   
##  [9] whisker_0.3-2  XML_3.95-0.2   xtable_1.7-1
```

