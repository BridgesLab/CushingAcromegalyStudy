Detailed Analysis of Cushing and Acromegaly Results
======================================================

Started with analysed DESeq files.  For this analysis, I am using the filtered deseq analysis, which removed the lower 40% expressing transcripts.  This file was most recently processed on ``Sun Aug 18 13:58:17 2013``.




The data is using the input files **../data/processed/cushing_deseq_results_filtered.csv** and **../data/processed/acromegaly_deseq_results_filtered.csv**.




The data was annotated from Ensembl data, using the biomaRt package (<a href="">Durinck et al. 2009</a>; <a href="">Durinck et al. 2005</a>).

Differentially Expressed Genes
--------------------------------
![plot of chunk differentially-expressed](figure/differentially-expressed1.png) ![plot of chunk differentially-expressed](figure/differentially-expressed2.png) 


### Acromegaly

There were **721** differentially expressed transcripts from the acromegaly patients, with **121** transcripts downregulated and **600** transcripts upregulated.

This corresponds to **156** upregulated genes and **43** downregulated genes.

### Cushing's Disease

There were **189** differentially expressed transcripts from the acromegaly patients, with **77** transcripts downregulated and **112** transcripts upregulated.

This corresponds to **39** upregulated genes and **19** downregulated genes.

Bibiography
------------

- Steffen Durinck, Paul Spellman, Ewan Birney, Wolfgang Huber,   (2009) Mapping identifiers for the integration of genomic datasets with the R/Bioconductor package biomaRt.  <em>Nature Protocols</em>  <strong>4</strong>  1184-1191
- Steffen Durinck, Yves Moreau, Arek Kasprzyk, Sean Davis, Bart  De Moor, Alvis Brazma, Wolfgang Huber,   (2005) BioMart and Bioconductor: a powerful link between biological databases and microarray data analysis.  <em>Bioinformatics</em>  <strong>21</strong>  3439-3440


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
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] biomaRt_2.16.0      knitcitations_0.5-0 bibtex_0.3-6       
## [4] knitr_1.4          
## 
## loaded via a namespace (and not attached):
## [1] digest_0.6.3   evaluate_0.4.7 formatR_0.9    httr_0.2      
## [5] RCurl_1.95-4.1 stringr_0.6.2  tools_3.0.1    XML_3.95-0.2  
## [9] xtable_1.7-1
```

