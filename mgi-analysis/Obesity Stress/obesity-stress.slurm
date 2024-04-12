#!  /bin/bash
#SBATCH --job-name ObesityStress
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=24G
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


# requires 30 mins and 64G
Rscript -e "rmarkdown::render('diabetes-diagnosis-data.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-encounter-data.Rmd')"
Rscript -e "rmarkdown::render('obesity-stress-data-entry.Rmd')"
#Rscript -e "rmarkdown::render('obesity-stress-demographics.Rmd')"
#Rscript -e "rmarkdown::render('obesity-stress-demographics-stress.Rmd')"
#Rscript -e "rmarkdown::render('obesity-stress-demographics-type2diabetes.Rmd')"
#Rscript -e "rmarkdown::render('obesity-stress-diabetes.Rmd')"
#Rscript -e "rmarkdown::render('obesity-stress-type2-diabetes.Rmd')"
#Rscript -e "rmarkdown::render('obesity-stress-diabetes-complicated.Rmd')"
#Rscript -e "rmarkdown::render('obesity-stress-liver.Rmd')"
#Rscript -e "rmarkdown::render('obesity-stress-hypertension.Rmd')"
