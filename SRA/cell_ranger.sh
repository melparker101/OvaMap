#!/bin/bash

# ----------------------------------------------------------
# Array script inception...
# Array scripts per project (n=6)
# Each array script per project resets as another array script for the number of samples in that project
# It then maps in-house IVF ovary RNA-seq data to a reference genome using cell ranger
# melodyjparker14@gmail.com - May 23
# ----------------------------------------------------------

#SBATCH -A lindgren.prj
#SBATCH -p short
#SBATCH -c 4
#SBATCH -J cell_ranger
#SBATCH -o logs/cell_ranger_project_%A_%a.out
#SBATCH -e logs/cell_ranger_project_%A_%a.err
#SBATCH -a 1-6

#  Parallel environment settings 
#  For more information on these please see the documentation 
#  Allowed parameters: 
#   -c, --cpus-per-task 
#   -N, --nodes 
#   -n, --ntasks 

echo "########################################################"
echo "Slurm Job ID: $SLURM_JOB_ID" 
echo "Run on host: "`hostname` 
echo "Operating system: "`uname -s` 
echo "Username: "`whoami` 
echo "Started at: "`date` 
echo "##########################################################"

###################################
# 1. Write a new script
###################################

if [[ -f run_cellranger.sh ]]; then
  echo '#!/bin/bash

  #SBATCH -A lindgren.prj
  #SBATCH -p short
  #SBATCH -c 4
  #SBATCH -J cell_ranger
  #SBATCH -o logs/cell_ranger_sample_%A_%a.out
  #SBATCH -e logs/cell_ranger_sample_%A_%a.err

  # Source .bashrc for the reference genome variable
  source ~/.bashrc

  # Load cellranger
  module load CellRanger/7.1.0

  # Define variables
  PROJECT=$1
  INDEX="$PROJECT"/"$PROJECT"_SraAccList.txt
  REF=$REF_GENOMES/homo_sapiens/10xgenomics/refdata-gex-GRCh38-2020-A
  FASTQ=raw_reads
  SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" "$INDEX")

  if [ !-d cellranger_count ]; then
    mkdir -p cellranger;
  fi
  cd cellranger

  # Run cellranger count
  cellranger count --id run_count_"$PROJECT" \
                   --transcriptome "$REF" \
                   --fastqs ../"$PROJECT"/"$FASTQ" \
                   --sample "$SAMPLE"

  echo "###########################################################"
  echo "Finished at: "`date`
  echo "###########################################################"
  exit 0

  ' > run_cellranger.sh

fi

###################################
# 2. Call the new script
###################################

# Set project number
index=("PRJNA766716" "PRJNA836755" "PRJNA792835" "PRJNA754050" "PRJNA879764" "PRJNA849410")
PROJECT=${index[$SLURM_ARRAY_TASK_ID]}

# Index file containing a list of samples for a particular project
INDEX="$PROJECT"/"$PROJECT"_SraAccList.txt

# Number of array scripts to send off
NSAMPLES=$(wc -l "$INDEX" | awk '{print $1}')  

# Submit the new script file to Slurm with the project number as the first argument
sbatch run_cellranger.sh --array=1-"$NSAMPLES" $PROJECT

                 
echo "###########################################################"
echo "Finished at: "`date`
echo "###########################################################"
exit 0
