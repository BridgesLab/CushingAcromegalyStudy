#!/bin/bash
#SBATCH --job-name ObesityStressCrossSection
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=40G
#SBATCH --time=02:00:00
#SBATCH --account=davebrid0
#SBATCH --partition=standard
#SBATCH --mail-user=davebrid@umich.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=/home/%u/logs/%x-%j.log
#SBATCH --error=/home/%u/error_logs/error-%x-%j.log

module purge
module load R
module load RStudio

echo "Running from $(pwd)"

# ── Phase 1: Data preparation (must run in this order) ──────────────────────
# Identifies T2D from ICD9/10 codes; generates ComorbidityDataAnnotated.csv
Rscript -e "rmarkdown::render('diabetes-diagnosis-data.Rmd')"

# Selects last (most recent) BMI per participant; generates LastEncounterAnthropometricsBMI.csv
Rscript -e "rmarkdown::render('obesity-stress-encounter-data.Rmd')"

# Merges all data sources; generates data-combined.csv
Rscript -e "rmarkdown::render('obesity-stress-data-entry.Rmd')"

# ── Phase 2: Descriptive / demographic analyses ──────────────────────────────
Rscript -e "rmarkdown::render('obesity-stress-demographics.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-demographics-stress.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-demographics-type2diabetes.Rmd')"

# ── Phase 2: Primary analysis ────────────────────────────────────────────────
Rscript -e "rmarkdown::render('stress-type2-diabetes.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-type2-diabetes.Rmd')"

# ── Phase 2: Secondary comorbidity analyses ──────────────────────────────────
Rscript -e "rmarkdown::render('obesity-stress-diabetes-complicated.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-liver.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-hypertension.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-chf.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-cpd.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-arythmia.Rmd')"
