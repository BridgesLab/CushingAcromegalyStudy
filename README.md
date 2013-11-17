Code and Raw Data for Acromegaly Analysis
===========================================

This data was analysed at first on the mbni and felix servers to generate counts tables.  The rest of the analysis was performed locally once the counts table was generated.  See the **processing** folder for the code used in the generation of these counts tables.

Data Files
------------

Data files are located in the **data** directory
The raw data in this analysis is located in **data/raw** and is the following files:

* **patient_table.csv** contains the measured parameters for these patients.
* **patient_legend.txt** describes the units used for measurements in the patient table.
* **patient_sample_mapping.csv** maps the patients to their corresponding samples.
* **transcript_counts_table.csv** has the transcript level counts table.
* **exon_counts_table.csv** has the exon level counts table.
* **acromegaly_patient_IGF1.csv** has the IGF-1 levels for the acromegaly patients.

Data files generated by these scripts are located in the **data/processsed** directory.

Script Files
---------------
Script files are saved in **scripts** folder and were analysed in this order

### counts_table_filtering.Rmd

This file filters the counts table to show only the most abundant transcript.  It starts with the file **data/raw/transcript_counts_table.csv** and then ends up with **data/processed/filtered_transcript_counts_table.csv.**

### deseq_analysis_outlier.Rmd

This file performs the DESeq analysis both including and removing the one outlier patient who was accidentally included in the analysis.  This script takes the files **data/processed/filtered_transcript_counts_table.csv.** and **data/raw/patient_sample_mapping.csv** and generages annoted DESeq results files for both cushing and acromegaly, as well as lists of statistically significant genes.

3. goseq-analysis.Rmd
4. heatmaps.Rmd 
5. barplots.Rmd
6. acromegaly_clinical_analysis.Rmd
7. GEO_comparasons.Rmd
8. igf_analysis.Rmd

Figures
-----------
The figures generated for the manuscript, via the running of these scripts are in the **figures** directory.  These figures are modified for final publication in the **manuscript** folder using Adobe Illustrator CS6.

Manuscript
------------
The manuscript files, including the manuscript, the figures, tables and supplementary data are in the **manuscript** directory.  Within this directory are the files generated for uploading the raw and processed data to the Gene Expression omnibus (in the folder **manuscript/GEO_submission**).
