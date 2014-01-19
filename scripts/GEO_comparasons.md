Comparason of Data from our Study with GEO Deposited Data
=============================================================


This script was most recently run on Sun Jan 19 11:00:02 2014.  





Huo et al Dataset
---------------------

The authors in <a href="http://dx.doi.org/10.1074/jbc.M508492200">Huo (2006)</a> treated 3T3-F442A adipocytes either with nothing or with HG for 0.5, 4 or 48h.  These data are in the dataset GSE2120.  I generated R code using GEO2R comparing the control and growth hormone treated samples at 48h.




### Upregulated Genes

Of the 430 significantly upregulated genes on the chip, 179 had identifiable human homologs, of which there were 225 probes.  These genes were on average **upregulated** to 1.0844 of their original control levels.  The p-value that these genes are upregulated is 0.0107.  Of these 225 mouse genes that had probes, 111 were upregulated.  Specifically, these genes were GGCT, FMO1, ABHD5, IGF1, GPM6B, PTGER3, PKN2, EVI5, HLTF, PLD1, CAPN6, GTF2I, NRD1, ACHE, RCOR1, STAG2, MYEF2, CCNE1, CCDC6, ALDOC, GAB1, AMBRA1, CD81, BMP5, CCNC, HMGCR, CCNG1, PRLR, CISH, GALNT3, ORC2, ATF2, SCP2, RRAGC, FBXL5, EPHX2, ITPR2, PLP1, GDF5, FGL2, GNAI1, CDKN1C, GFAP, GRSF1, ERCC5, SRPK2, GLUL, SLTM, STAT4, RGS3, SDSL, ESYT1, AKT1, GOLGA4, ZMYM4, IGFBP3, AUH, STOM, TCF7L2, SIDT2, ADRA2A, GJA1, CD96, TRIP12, GNA14, ZYG11B, AK4, AZI2, SERPINI1, ABCA1, GKAP1, CYB5A, MAPRE2, UGP2, TOR1AIP2, FOXN2, KCNK3, PTEN, CALB2, RHOD, UNC5C, KCNA4, SH3BGR, DRG1, PRR5, CHP1, TCEA1, ADH1A, ADRB3, ADH1B, MAN1A2, ADH1C, EID1

### Downregulated Genes

Of the 241 significantly downregulated genes, 109 had identifiable human homologs on that array chip, of which there were 123 probes.  These genes were on average **downregulated** to 0.9508 of their original control levels.  The p-value that these genes are downregulated is 0.0576.  Of these 123 mouse genes that had probes, 52 were downregulated.  Specifically, these genes were ABCC2, HOMER3, U2AF2, NTN1, TCF3, PTPN18, WNT11, PPP1R15A, SH3BP2, TBC1D10A, LGALS1, KIAA0930, RENBP, STX4, IKBKB, TRMT1, CCL8, BST1, LTBR, CTGF, ATP8A1, ZFP36, PSME3, GOLM1, PSAT1, RDH5, SLC7A1, RTN1, IMPA2, TNFRSF11A, GPC3, CDKN2B, TENM4, DCK, NTAN1, GALNT10, MAPK7, NDST2, STAT6, SLC3A2, SHOX2, FOS, JUNB, GAS6, KCNJ12, CSF1, MAFF, RASA3, APOD, RYR1, TCEA3, RP1-130H16.18.

### Enrichment Testing
We found 671 significantly different genes in the acromegaly study.  Our re-analysis of the growth hormone study found 560 differentially expressed genes.  That corresponds to 6.0929% of the genes are different.  Out of those genes, 432 map to human homologs.  Out of the transcripts mapped to those genes, 30 out of 429 (or 6.993%)` were significantly different in the acromegaly data, so there was no enrichment.

Done the other way, we found 671 significantly different acromegaly genes out of a total of 58899 genes tested (or 1.1392%).  Out of these 671 genes, 288 have mouse homologs, and 346 probes in this dataset.  From these probes, 32 were significant (or 8.2219%).  Therefore the genes from the acromegaly dataset are enriched in the growth hormone treated dataset (p=5.4617 &times; 10<sup>-4</sup>).  The genes which were significant in both datasets were Cish, Pkd2, Itpr2, Pld1, Fmo1, Phldb2, Wnt11, Unc5c, Bst1, Fhod3, Igsf10, Ccng1, Mpdz, Prlr, Sept4, Wisp2, Pten, Ggct, Igfbp3, Igf1, Scd2, Scp2, Ptger3, Capn6, Il1rl1, Evi5, Fasn, Gdf5, Klf4

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
## [1] biomaRt_2.18.0      limma_3.18.7        GEOquery_2.28.0    
## [4] Biobase_2.22.0      BiocGenerics_0.8.0  knitcitations_0.5-0
## [7] bibtex_0.3-6        devtools_1.4.1      knitr_1.5          
## 
## loaded via a namespace (and not attached):
##  [1] digest_0.6.4   evaluate_0.5.1 formatR_0.10   httr_0.2      
##  [5] memoise_0.1    RCurl_1.95-4.1 stringr_0.6.2  tools_3.0.2   
##  [9] whisker_0.3-2  XML_3.95-0.2   xtable_1.7-1
```

