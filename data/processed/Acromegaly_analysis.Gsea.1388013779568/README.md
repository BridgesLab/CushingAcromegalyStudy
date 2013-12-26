The GSEA was done using the JavaGSEA Desktop Application (v.2.0.13)  

Input files preparation
-----------------------------------
This step was done in Excel unless stated otherwise and files were saved in the *data/processed/* folder.

### Generation of the expression dataset file

1.  Sort the “Normalized Counts Table No Outlier.csv” file by the ID column (A to Z)
2.	Sort the “Annotated DESeq Results without Outlier – Acromegaly.csv” file by ID column (A to Z)
3.	Copy the EntrezGeneName, ID, and padj from “Annotated DESeq Results without Outlier – Acromegaly.csv” file to the “Normalized Counts Table No Outlier.csv”.  These two files are matched by ID.
4.	Save the "Normalized Counts Table No Outlier.csv"" file as "GSEA_input_Acromegaly_DESeq_Annotated.txt".
5.	Sort the “GSEA_input_Acromegaly_DESeq_Annotated.txt” by padj column from smallest to largest.
6.	Keep only genes that have padj < 0.05 in the “GSEA_input_Acromegaly_DESeq_Annotated.txt” file.
7.  Delete all samples that are Cushing's.

Since there is no chip platform annotation for RNA-seq, make sure the **Name** column in the expression dataset file contain the **Gene Symbol** so that it can be mapped with the Gene sets database which uses the GENE_SYMBOL.chip info.


### Generation of the phenodata file

This file was created based on the "data/raw/patient_sample_mapping.csv".  Rearrange the expression dataset so that all control samples are together in a group and all acromegaly samples are in a group to match with the phenodata file.  This phenodata was saved in "data/process/GSEA_pheno_Acromegaly.cls".

### Generation of the gene sets file.  

This step was done using the **Browse MSigDB** feature in the GSEA application using the *msigdb_v4.0.xml* database. The gene sets file was exported  with these options:
- Collection: All
- Organisim: Homo sapiens
- Chip: EntrezGeneIds
- Contributer: All

The file was exported using *GeneSetMatrix[gmx]* format and *GENE_SYMPBOL.chip* as target chip. The file was named "export_.gseaftp.broadinstitute.org___pub_gsea_annotations_GENE_SYMBOL.chip.gmx".

GSEA Analysis
-------------------------
Load data: browse to the location where the above 3 files are located and import them to GSEA application.

Run GSEA: select the appropriate file to the appropriate field. The analysis was run with these specified options. Other options were left as they were by default.

- Collapse dataset to gene symbols: False
- Permuation type: phenotype
- Chip platform(s): leave empty
- Analysis name: Acromegaly_analysis
- Max size - exclude larger sets: 100
- Min size - exclude smaller sets: 3

The result was output to a folder named "data/processed/Acromegaly_analysis.Gsea.1388013779568/".
