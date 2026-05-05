To do this analysis we requested data from Michigan Medicine Data Direct, most recently on 2025-05-08. Data are split between cases (those with Cushing's disease) and controls (teh general population).  Note that most of these csv files are not available in the Github respository due to data sharing restrictions.

## Data Cleaning Steps

- `procedure-date.qmd` Generates uses EncounterAll, ProceduresComprehensive, DiagnosesComprehensiveAll and generates **CushingsDataClean**
- `demographic_cleaning.qmd` analyzes demographics for cases, uses CushingsDataClean,  DemographicInfo, GisNeighborhoodAffluence and EncounterAll.  This file generates **ControlDemographics.csv** and **CaseDemographics.csv** merging in their emographics and neighborhood SES.
- `prior_lab_results.qmd` analysed the lab results before diagnoses.  Uses EncounterAll, EncounterAnthropometricsBMI, DiagnosesComprehensiveAll, ComorbiditiesCharlsonComprehensive, ComorbiditiesElixhauserComprehensive, LabResults and CushingsDataClean

## Analysis

- `propensity_mapping.qmd` loads in the cases and does outcome-specific propensity mapping and then the analyses for each outcome.  This is where the majority of the data analyses are done.