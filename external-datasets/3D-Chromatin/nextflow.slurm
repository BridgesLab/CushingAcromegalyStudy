#!/bin/bash
#SBATCH --job-name=nf-3Dtad
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2-00:00:00
#SBATCH --account=davebrid0
#SBATCH --partition=standard
#SBATCH --mail-user=davebrid@umich.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --output=/home/%u/logs/%x-%j.log
#SBATCH --error=/home/%u/error_logs/error-%x-%j.log

# ---------------------------------------------------------------------------
# Nextflow ORCHESTRATOR job (tiny: 1 core / 4 GB).
# With executor='slurm' in nextflow.config, this process does NOT run the
# pipeline itself — it only submits each task (DOWNLOAD_HIC, BUILD_COOL,
# CALL_TADS_*, …) as its own SLURM job and monitors them. Those child jobs do
# the real compute and run in parallel (up to executor.queueSize), each with its
# own walltime. This job just needs to stay alive for the whole run.
#
# First run builds the per-process conda envs (cooler / cooltools / hicexplorer)
# under ./work/conda; subsequent -resume runs reuse them. Make sure `conda`
# (and ideally `mamba`) are on PATH in the env you launch from.
# ---------------------------------------------------------------------------

set -euo pipefail
echo "Orchestrator running from $(pwd) on $(hostname)"

# module load Nextflow      # if nextflow is a module on your setup
nextflow -version

# -resume reuses cached downloads / coolers / finished TAD calls.
nextflow run main.nf -resume

echo "Nextflow orchestrator finished."
