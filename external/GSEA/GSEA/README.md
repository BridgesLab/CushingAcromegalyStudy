The GSEA was done using the JavaGSEA Desktop Application (v.2.0.13)  

Input files preparation
-----------------------------------
This step was done in Excel unless stated otherwise and files were saved in the *GSEA* folder.

### Generation of the expression dataset file

1.  Sort the “Normalized Counts Table No Outlier.csv” file by the ID column (A to Z)
4.  Save this file as "GSEA_expression_input_Acromegaly.txt".
3.  Sort the “Annotated DESeq Results without Outlier – Acromegaly.csv” file by ID column (A to Z)
4.	Copy the ensemble_gene_id, and external_gene_id from “Annotated DESeq Results without Outlier – Acromegaly.csv” file to the “GSEA_expression_input_Acromegaly.txt”.  These two files are matched by ID.
5.  Delete all samples that are Cushing's.

Since there is no chip platform annotation for RNA-seq, make sure the **Name** column in the expression dataset file contain the **Gene Symbol** so that it can be mapped with the Gene sets database which uses the GENE_SYMBOL.chip info.

### Generation of the phenodata file

This file was created based on the "data/raw/patient_sample_mapping.csv".  Rearrange the expression dataset so that all control samples are together in a group and all acromegaly samples are in a group to match with the phenodata file.  This phenodata was saved in "GSEA/GSEA_pheno_Acromegaly.cls".

### Generation of the gene sets file.  

GSEA Analysis
-------------------------
Load data: browse to the location where the above 2 files are located and import them to GSEA application.

Run GSEA: 
- Select the appropriate file to the appropriate field. 
- Select the *c5.all.v4.0.symbols.gmt* gene matrix from the website as the "Gene sets database".

The analysis was run with these specified options. Other options were left as they were by default.

- Collapse dataset to gene symbols: False
- Permuation type: phenotype
- Chip platform(s): leave empty

Click the "show"" button to open the Basic fields.  Change the options of these two fields

- Analysis name: Acromegaly_analysis
- Enrichment statistic: weighted
- Metric for ranking genes: Ratio_of_classes
- Gene list sorting mode: real
- Gene list ordering mode: descending
- Max size: 500
- Min size: 15

The result was output to a folder named "GSEA/Acromegaly_vs_CON.Gsea.1389045881613/".
