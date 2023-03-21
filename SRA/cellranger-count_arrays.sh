#!/bin/bash

# ----------------------------------------------------------
# This script sends off an array of scripts to run the cellranger count pipeline for each run in a given project
# Specify the project accession number as the first argument for this script
# melodyjparker14@gmail.com - Mar 23
# ----------------------------------------------------------


#SBATCH -A lindgren.prj
#SBATCH -p short
#SBATCH -c 5
#SBATCH -J cellranger-c_array
#SBATCH -o logs/cellranger-count_%a_output.out

#  Parallel environment settings
#  For more information on these please see the documentation
#  Allowed parameters:
#   -c, --cpus-per-task
#   -N, --nodes
#   -n, --ntasks


PROJECT=$1
INDEX="$PROJECT"/"$PROJECT"_SraAccList.txt
NLINE=$(wc -l "$INDEX" | awk '{print $1}')  # How many array scripts to send off


# Check to see if this is running as an array task. If not, replace this process with a SLURM array, with one task per ID.
if [[ "$SLURM_ARRAY_TASK_ID" == "" ]]; then
  echo "########################################################"
  echo "Slurm Job ID: $SLURM_JOB_ID" 
  echo "Run on host: "`hostname` 
  echo "Operating system: "`uname -s` 
  echo "Username: "`whoami` 
  echo "Started at: "`date` 
  echo "##########################################################"
  # Relaunch this script as an array
  echo ""
  echo "Sending off array scripts..."
  echo "Read accession numbers (n="$NLINE"):"
  exec sbatch --array=1-"$NLINE" "$0" "$1"
fi


# Load cellranger
module load CellRanger/7.1.0


# Define variables
REF=refdata-gex-GRCh38-2020-A
FASTQ=raw_reads
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}"'q;d' "$INDEX")


if [ !-d cellranger_count ]; then
  mkdir -p cellranger;
fi
cd cellranger


# Run cellranger count
cellranger count --id run_count_"$PROJECT" \
                 --transcriptome ../"$REF" \
                 --fastqs ../"$PROJECT"/"$FASTQ" \
                 --sample "$SAMPLE"
                 
                 
echo "###########################################################"
echo "Finished at: "`date`
echo "###########################################################"
exit 0            
