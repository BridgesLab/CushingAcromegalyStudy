#!/bin/bash
#SBATCH --job-name=nf-GRchip
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
# pipeline itself — it only submits each task (CHIP_ALIGN, MACS2_CALLPEAK, …)
# as its own SLURM job and monitors them. Those child jobs do the real compute
# and run in parallel (up to executor.queueSize), each with its own walltime.
# This job just needs to stay alive for the whole run, hence the 2-day --time.
# ---------------------------------------------------------------------------

set -euo pipefail
echo "Orchestrator running from $(pwd) on $(hostname)"

# Make `nextflow` (and its Java runtime) available. The `(base)` conda env you
# launch from already has nextflow on PATH in your setup; if you instead use a
# module, swap the line below (e.g. `module load Nextflow` or a java module).
# module load Nextflow
nextflow -version

# -resume reuses cached genome builds / blacklists / finished alignments.
nextflow run main.nf -resume

echo "Nextflow orchestrator finished."
