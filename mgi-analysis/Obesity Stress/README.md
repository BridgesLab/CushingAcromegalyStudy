Analysis scripts and results for the stress-obesity project using MGI data. Raw patient data are not present here, as they are protected under IRB HUM00071298. All scripts are run on the armis secure server where the data reside.

For details on the MGI cohort see:

Zawistowski M, Fritsche LG, Pandit A, Vanderwerff B, Patil S, Schmidt EM, VandeHaar P, Willer CJ, Brummett CM, Kheterpal S, Zhou X, Boehnke M, Abecasis GR, Zöllner S. The Michigan Genomics Initiative: A biobank linking genotypes and electronic clinical records in Michigan Medicine patients. Cell Genom. 2023 Jan 31;3(2):100257. doi: 10.1016/j.xgen.2023.100257. PMID: 36819667; PMCID: PMC9932985.

# Structure

This folder contains two independent analyses. Each has its own scripts, README, and SLURM submission file, and should be run as a self-contained unit from its own directory on armis.

## `cross-sectional/`

A cross-sectional analysis of perceived stress, obesity, and prevalent Type 2 diabetes. Uses the **last (most recent)** recorded BMI per participant. This analysis is complete and has a companion manuscript (`manuscript/Obesity-Stress/`).

See [`cross-sectional/README.md`](cross-sectional/README.md) for the full script execution order and output file descriptions. Submit via `cross-sectional/cross-sectional.slurm`.

## `longitudinal/`

A longitudinal analysis examining incident Type 2 diabetes after enrollment. Uses the BMI measurement **closest to the survey/enrollment date** (within 365 days) to anchor the obesity exposure to the same time as the stress measurement. This analysis is in development — no companion manuscript yet.

See [`longitudinal/README.md`](longitudinal/README.md) for current scripts and development notes. Submit via `longitudinal/longitudinal.slurm`.

# Key Distinction Between Analyses

| | Cross-sectional | Longitudinal |
|---|---|---|
| BMI definition | Last recorded BMI | BMI closest to survey date |
| T2D outcome | All prevalent diagnoses | Incident diagnoses after enrollment |
| Status | Complete (manuscript in review) | In development |
| SLURM file | `cross-sectional/cross-sectional.slurm` | `longitudinal/longitudinal.slurm` |

# Armis Setup Note

Both analyses share the same raw input files (e.g., `ClarityMedicalHistory.csv`, `EncounterAnthropometricsBMI.csv`). On armis, place the raw data files in each working subdirectory, or use symlinks pointing to a shared data location. Each SLURM file assumes it is submitted from within its own subdirectory.
