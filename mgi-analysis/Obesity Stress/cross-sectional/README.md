Scripts and results for the **cross-sectional** analysis of perceived stress, obesity, and Type 2 diabetes in the MGI cohort. The actual data are not present here, as they are protected under IRB HUM00071298. All scripts are run on the armis secure server where the raw data reside.

For the companion manuscript see `manuscript/Obesity-Stress/`.

For details on the MGI cohort see:

Zawistowski M, Fritsche LG, Pandit A, Vanderwerff B, Patil S, Schmidt EM, VandeHaar P, Willer CJ, Brummett CM, Kheterpal S, Zhou X, Boehnke M, Abecasis GR, Zöllner S. The Michigan Genomics Initiative: A biobank linking genotypes and electronic clinical records in Michigan Medicine patients. Cell Genom. 2023 Jan 31;3(2):100257. doi: 10.1016/j.xgen.2023.100257. PMID: 36819667; PMCID: PMC9932985.

# Analysis on Server

Submit `cross-sectional.slurm` from this directory on armis. Scripts must run in the order below.

## Phase 1: Data Preparation (sequential)

* **diabetes-diagnosis-data.Rmd** — Identifies Type 2 diabetes diagnoses from ICD9 (`250.x "type II"`) and ICD10 (`E11.*`) codes in `ClarityMedicalHistory.csv`. Annotates the Elixhauser comorbidity table (`ComorbiditiesElixhauserComprehensive.csv`) with a `Type2Diabetes` flag and first diagnosis date. Generates `ComorbidityDataAnnotated.csv`.

* **obesity-stress-encounter-data.Rmd** — Takes longitudinal BMI encounter records (`EncounterAnthropometricsBMI.csv`) and selects the **last (most recent)** BMI per participant, filtering implausible values (BMI 9–129 kg/m²). Generates `LastEncounterAnthropometricsBMI.csv`.

* **obesity-stress-data-entry.Rmd** — Merges all data sources: survey data (`MGIPatientReportedSurveys.csv`), demographics (`DemographicInfo.csv`), comorbidities (`ComorbidityDataAnnotated.csv`), last BMI (`LastEncounterAnthropometricsBMI.csv`), and GIS neighborhood affluence scores (`GisNeighborhoodAffluence.csv`). Applies inclusion criteria (must have BMI, age group, and stress score). Creates derived variables: six-level and binary BMI categories, stress dichotomized at the sample median, and race/ethnicity groupings. Generates `data-combined.csv`, the input for all downstream scripts.

## Phase 2: Analyses (all read from `data-combined.csv`)

### Descriptive / Demographic

* **obesity-stress-demographics.Rmd** — Cross-tabulations of demographics stratified by stress and obesity status.

* **obesity-stress-demographics-stress.Rmd** — Demographic correlates of perceived stress; univariate binomial regression for each covariate. Generates `Stress Demographics Table.csv` (Table 1 of manuscript).

* **obesity-stress-demographics-type2diabetes.Rmd** — Demographic correlates of Type 2 diabetes status.

### Primary Analysis

* **stress-type2-diabetes.Rmd** — Association between perceived stress and Type 2 diabetes. Builds multivariable logistic models stepwise (unadjusted → + obesity → + gender → + age → + race/ethnicity → + neighborhood SES). Tests effect modification by obesity (obese vs. non-obese and across all six BMI classes). Generates `Multivariable Analysis of Stress-Diabetes Associations.csv`, `Obesity-Stress Interaction Table.csv`, and `Obesity-Stress Interaction Table by Class.csv` (Tables 2 & 3 of manuscript).

* **obesity-stress-type2-diabetes.Rmd** — Visualizations of Type 2 diabetes prevalence by BMI × stress, stratified by sex, race/ethnicity, and neighborhood disadvantage (Figures 2A–2D of manuscript).

### Secondary / Comorbidity Analyses

* **obesity-stress-diabetes-complicated.Rmd** — Stress, obesity, and complicated diabetes (Elixhauser-defined).

* **obesity-stress-liver.Rmd** — Stress, obesity, and liver disease.

* **obesity-stress-hypertension.Rmd** — Stress, obesity, and hypertension.

* **obesity-stress-chf.Rmd** — Stress, obesity, and congestive heart failure.

* **obesity-stress-cpd.Rmd** — Stress, obesity, and chronic pulmonary disease.

* **obesity-stress-arythmia.Rmd** — Stress, obesity, and cardiac arrhythmia.

# Output Summary Files

These CSVs are summary-level outputs used in the manuscript. They contain no individual-level patient data.

| File | Source Script |
|---|---|
| `Stress Demographics Table.csv` | obesity-stress-demographics-stress.Rmd |
| `Type 2 Diabetes Demographics Table.csv` | obesity-stress-demographics-type2diabetes.Rmd |
| `Multivariable Analysis of Stress-Diabetes Associations.csv` | stress-type2-diabetes.Rmd |
| `Obesity-Stress Interaction Table.csv` | stress-type2-diabetes.Rmd |
| `Obesity-Stress Interaction Table by Class.csv` | stress-type2-diabetes.Rmd |

> **Note:** `comorbidity_data.csv` and `multivariate_data.csv` are present in this folder but their exact provenance (which script generated them and under what variable definitions) is not yet documented. These should be traced back before relying on them.
