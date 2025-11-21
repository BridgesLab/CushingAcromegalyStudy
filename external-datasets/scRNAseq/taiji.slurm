#!  /bin/bash
#SBATCH --job-name taiji-zhang
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G
#SBATCH --time=03:00:00
#SBATCH --account=davebrid0
#SBATCH --partition=standard
#SBATCH --mail-user=davebrid@umich.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=/home/%u/%x-%j.log
#SBATCH --error=/home/%u/error-%x-%j.log

module purge
module load samtools
module load py-macs2
module load bwa

echo "Running from $(pwd)"

taiji run --config zhang-config.yml -n 16 +RTS -N16
