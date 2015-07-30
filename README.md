<!-- Open Knowledge Link -->
 <a href="http://opendefinition.org/">
 <img alt="This material is Open Knowledge" border="0"
  src="http://assets.okfn.org/images/ok_buttons/ok_80x15_blue.png" /></a>
<!-- /Open Knowledge Link -->

Code and Raw Data for Acromegaly and Cushing Analyses
========================================================

This repository contains raw data for studies done by the [Bridges Lab](http://bridgeslab.uthsc.edu) and our collaborators on the neuroendocrine disorders Cushing's disease and Acromegaly.  This repository contains the data for several manuscripts as detailed below.  The tag column indicates the state of the dataset at the indicated time.:

| Publication | Dataset | Tag |
|-------------|---------|-----|
| 1. I. Hochberg, I. Harvey, Q. T. Tran, E. J. Stephenson, A. L. Barkan, A. Saltiel, W. F. Chandler, D. Bridges, Gene expression changes in subcutaneous adipose tissue due to Cushing’s disease., *J. Mol. Endocrinol*. Accepted (2015), [doi:10.1530/JME-15-0119](http://dx.doi.org/10.1530/JME-15-0119). |  ![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.13367.svg)](http://dx.doi.org/10.5281/zenodo.13367) |  [Cushing-v1.0.0](https://github.com/BridgesLab/CushingAcromegalyStudy/releases/tag/Cushing-v1.0.0) |
| 1. I. Hochberg, Q. T. Tran, A. L. Barkan, A. R. Saltiel, W. F. Chandler, D. Bridges, Gene Expression Signature in Adipose Tissue of Acromegaly Patients, PLoS One 10, e0129359 (2015). [doi:10.1371/journal.pone.0129359](http://dx.doi.org/10.1371/journal.pone.0129359)|     [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.13367.svg)](http://dx.doi.org/10.5281/zenodo.13367) |  [Acromegaly-v1.0.0](https://github.com/BridgesLab/CushingAcromegalyStudy/releases/tag/Acromegaly-v1.0.0) |


This data was analysed at first on the mbni and felix servers to generate counts tables.  The rest of the analysis was performed locally once the counts table was generated.  See the **processing** folder for the code used in the generation of these alignments and counts tables.

Licence
--------
This CushingAcromegalyStudy data is made available under the Open Data Commons Attribution License: http://opendatacommons.org/licenses/by/1.0. - See more at: http://opendatacommons.org/licenses/by/#sthash.i6n4YNvv.dpuf

Data Files
------------

Data files are located in the **data** directory
The raw data in this analysis is located in **data/raw** and is the following files:


Script Files
---------------
Script files are saved in **scripts** folder and were analysed in this order

Figures
-----------
The figures generated for the manuscript, via the running of these scripts are in the **figures** directory.  These figures are modified for final publication in the **manuscript** folder using Adobe Illustrator CS6.

Manuscript
------------
The manuscript files, including the manuscript, the figures, tables and supplementary data are in the **manuscript** directory.  Within this directory are the files generated for uploading the raw and processed data to the Gene Expression omnibus (in the folder **manuscript/GEO_submission**).
