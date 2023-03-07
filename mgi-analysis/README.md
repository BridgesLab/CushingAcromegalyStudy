This folder contains the analytical scripts and the results (html and md files) for the stress-obesity project using MGI data.  The actual data is not present, so these scripts *cannot be reproducibly run*, as the data is protected based on HUM00071298.  For more details see:

Zawistowski M, Fritsche LG, Pandit A, Vanderwerff B, Patil S, Schmidt EM, VandeHaar P, Willer CJ, Brummett CM, Kheterpal S, Zhou X, Boehnke M, Abecasis GR, Zöllner S. The Michigan Genomics Initiative: A biobank linking genotypes and electronic clinical records in Michigan Medicine patients. Cell Genom. 2023 Jan 31;3(2):100257. doi: 10.1016/j.xgen.2023.100257. PMID: 36819667; PMCID: PMC9932985.

As such all these scripts are run separately on the armis secure server where the input files reside.

# Prior Steps

# Analysis on server

Ran slurm file to execute scripts in this order

* **obesity-stress-encounter-data.Rmd** to take encounters and get a single BMI for each participant.  This generates a file with median BMI for each participant.
* **obesity-stress-data-entry.Rmd** to integrate the data (surveys/demographics, comorbidities and BMI).  This generates the final combined datafile used for the rest of the scripts
* **obesity-stress-demographics.Rmd** to analyse demographics with respect to stress levels
* **obesity-stress-demographics-diabetes.Rmd** to analyse demographics with respect to diabetes 
* **obesity-stress-diabetes.Rmd** to analyse the relationships between stress, obesity and diabetes
* **obesity-stress-diabetes-complicated.Rmd** to analyse the relationships between stress, obesity and complicated diabetes
* **obesity-stress-liver.Rmd** to analyse the relationships between stress, obesity and liver disease
* **obesity-stress-hypertension.Rmd** to analyse the relationships between stress, obesity and hypertension





