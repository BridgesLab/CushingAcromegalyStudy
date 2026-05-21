Scripts for the **longitudinal** analysis of perceived stress, obesity, and Type 2 diabetes in the MGI cohort. The actual data are not present here, as they are protected under IRB HUM00071298. All scripts are run on the armis secure server where the raw data reside.

This analysis is currently in development. There is no companion manuscript yet.

**Key distinction from the cross-sectional analysis:** Rather than the last recorded BMI, this analysis uses the BMI measurement closest in time to the survey/enrollment date (within 365 days). This anchors the obesity exposure to the same moment as the stress measurement, which is more appropriate for a longitudinal design examining incident outcomes after enrollment.

# Analysis on Server

Submit `longitudinal.slurm` from this directory on armis. Scripts must run in the order below.

## Phase 1: Data Preparation (sequential)

* **diabetes-diagnosis-data.Rmd** — Identifies Type 2 diabetes diagnoses from ICD9 (`250.x "type II"`) and ICD10 (`E11.*`) codes in `ClarityMedicalHistory.csv`. Annotates the Elixhauser comorbidity table with a `Type2Diabetes` flag and first diagnosis date. Generates `ComorbidityDataAnnotated.csv`. *(Shared with cross-sectional analysis — identical script.)*

* **obesity-stress-encounter-enrollment-data.Rmd** — Matches each participant's BMI encounter records to their survey date and selects the BMI measurement closest in time (within 365 days of survey). Generates `SurveyAnthropometricsBMI.csv`.

## Phase 2: Analysis

* **obesity-stress-type2-diabetes-longitudinal.Rmd** — Longitudinal analysis of stress and Type 2 diabetes using the survey-proximal BMI. *In development.*

# Notes for Development

- A data-entry integration script (analogous to `cross-sectional/obesity-stress-data-entry.Rmd`) will be needed to merge `SurveyAnthropometricsBMI.csv`, `ComorbidityDataAnnotated.csv`, demographics, and GIS data into a single analysis file.
- The primary outcome should be restricted to Type 2 diabetes diagnoses made **after** the survey date to avoid reverse causality (use `DeID_Diabetes_Diagnosis` date from `ComorbidityDataAnnotated.csv` relative to `DeID_Survey_Date`).
- This analysis requires dates for BMI encounters (see TODO in cross-sectional/TODO.md).
