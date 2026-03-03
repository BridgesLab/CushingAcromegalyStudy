<!-- Open Knowledge Link -->
 <a href="http://opendefinition.org/">
 <img alt="This material is Open Knowledge" border="0"
  src="http://assets.okfn.org/images/ok_buttons/ok_80x15_blue.png" /></a>
<!-- /Open Knowledge Link -->

# Code and Raw Data for Acromegaly and Cushing Analyses

This repository contains raw data for studies done by the [Bridges Lab](http://bridgeslab.sph.umich.edu) and our collaborators on the neuroendocrine disorders Cushing's disease and Acromegaly.  This repository contains the data for several manuscripts as detailed below.  The tag column indicates the state of the dataset at that time.:

| Publication | Dataset | Tag |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| Hochberg, I, I. Harvey, Q. T. Tran, E. J. Stephenson, A. L. Barkan, A. Saltiel, W. F. Chandler, D. Bridges. Gene expression changes in subcutaneous adipose tissue due to Cushing’s disease. *Journal of Molecular Endocrinology*. 55(2):81-94 (2015). [doi:10.1530/JME-15-0119](http://dx.doi.org/10.1530/JME-15-0119). | [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.22193.svg)](http://dx.doi.org/10.5281/zenodo.22193) | [Cushing-v1.0.0](https://github.com/BridgesLab/CushingAcromegalyStudy/releases/tag/Cushing-v1.0.0) |
| Hochberg, I, Q. T. Tran, A. L. Barkan, A. R. Saltiel, W. F. Chandler, D. Bridges. Gene Expression Signature in Adipose Tissue of Acromegaly Patients, *PLoS One* 10, e0129359 (2015). [doi:10.1371/journal.pone.0129359](http://dx.doi.org/10.1371/journal.pone.0129359) | [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.22192.svg)](http://dx.doi.org/10.5281/zenodo.22192) | [Acromegaly-v1.0.0](https://github.com/BridgesLab/CushingAcromegalyStudy/releases/tag/Acromegaly-v1.0.0) |
| Harvey, I., E. J. Stephenson, J. R. Redd, Q. T. Tran, I. Hochberg, N. Qi, D. Bridges. Glucocorticoid-Induced Metabolic Disturbances Are Exacerbated in Obese Male Mice, *Endocrinology* 159(6):1-15 (2018).  [doi:10.1210/en.2018-00147](https://doi.org/10.1210/en.2018-00147)| [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1226532.svg)](https://doi.org/10.5281/zenodo.1226532)| [Obesity-v1.0.0](https://github.com/BridgesLab/CushingAcromegalyStudy/releases/tag/Obesity-v1.0.0) |
| Gunder, L.C., I. Harvey,  J. R. Redd, C. S. Davis, A. AL-Tamimi, S. V. Brooks and D. Bridges. Obesity Augments Glucocorticoid-Dependent Muscle Atrophy in Male C57BL/6J Mice, *Biomedicines* 2020, 8(10), 420.  [doi:10.3390/biomedicines8100420](https://doi.org/110.3390/biomedicines81004206) |[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3988330.svg)](https://doi.org/10.5281/zenodo.3988330) | [Muscle-v1.0.0](https://github.com/BridgesLab/CushingAcromegalyStudy/releases/tag/Muscle-v1.0.0)|
| Carr, T.C.,  I. Hochberg and D. Bridges. Differential Metabolic Signatures of Cushing’s Disease Patients Dependent on their Obesity Status. *medRxiv*.  [doi:10.64898/2026.02.25.26346994](https://doi.org/10.64898/2026.02.25.26346994) | | [Cushings-Obesity-v0.1.0](https://github.com/BridgesLab/CushingAcromegalyStudy/releases/tag/Cushings-Obesity-v0.1.0)|


### RNAseq Datasets

RNAseq datasets can be found at the Gene Expression Omninus (GEO):

- **The Cushing's disease adipose gene expression profile reveals effects of long term glucocorticoids on adipose tissue lipid, protein and glucose metabolism.** Described in Hochberg *et al.* (2015) Journal of Molecular Endocrinology [doi:10.1530/JME-15-0119](http://dx.doi.org/10.1530/JME-15-0119).  Can be found on GEO at [GSE66446](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE66446)
- **Gene Expression Signature in Adipose Tissue of Acromegaly Patients.**. Described in Hochberg *et al*. (2015) PLOS One [doi:10.1371/journal.pone.0129359](http://dx.doi.org/10.1371/journal.pone.0129359).  Can be found on GEO at [GSE57803](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE57803)

## Data Files and Analysis Scripts

- Data files and scripts are located in the **data** directory.
- Human data analysis scripts (raw data is not available due to IRB restrictions) are found in the **mgi_data** directory.
- Secondary data analyses can be found in the **external_data** directory.

## Manuscripts

The manuscript files, including the manuscript, the figures, tables and supplementary data are in the **manuscript** directory.  To locate the raw data sources for each figure or table, see the README files within each manuscript's directory.  The figures generated for the manuscript, via the running of these scripts are in the **figures** directories within data/mgi_data/external_data.  These figures are modified for final publication in the **manuscript** folder using Adobe Illustrator.

# Licence

This CushingAcromegalyStudy data is made available under the Open Data Commons Attribution License: http://opendatacommons.org/licenses/by/1.0.  For more information see [LICENSE](https://github.com/BridgesLab/CushingAcromegalyStudy/blob/master/LICENSE)