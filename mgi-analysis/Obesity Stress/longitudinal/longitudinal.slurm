#!/bin/bash
#SBATCH --job-name ObesityStressLongitudinal
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

# Selects BMI closest to survey/enrollment date (within 365 days);
# generates SurveyAnthropometricsBMI.csv
Rscript -e "rmarkdown::render('obesity-stress-encounter-enrollment-data.Rmd')"

# ── Phase 2: Primary analysis ────────────────────────────────────────────────
Rscript -e "rmarkdown::render('obesity-stress-type2-diabetes-longitudinal.Rmd')"
