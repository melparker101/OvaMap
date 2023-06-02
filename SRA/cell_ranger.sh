#!/bin/bash

# ----------------------------------------------------------
# Script to map in-house IVF ovary RNA-seq data to a reference genome using cell ranger
# melodyjparker14@gmail.com - May 23
# ----------------------------------------------------------

#SBATCH -A lindgren.prj
#SBATCH -p short
#SBATCH -c 4
#SBATCH -J cell_ranger
#SBATCH -o logs/cell_ranger_%a.out
#SBATCH -e logs/cell_ranger_%a.err
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


# Choose datasets to use
index=("PRJNA766716" "PRJNA836755" "PRJNA792835" "PRJNA754050" "PRJNA879764" "PRJNA849410")
PROJECT=${index[$SLURM_ARRAY_TASK_ID]}

REF=$REF_GENOMES/homo_sapiens/10xgenomics

# Load modules
module load CellRanger/7.1.0

# --sample $READ excluded as we want to use all (S1)
# Run cellranger to align and quantify
cellranger count --id run_count_"$PROJECT" --transcriptome "$REF"/refdata-gex-GRCh38-2020-A.tar.gz \
                 --fastqs "$PROJECT"/raw_reads
                

echo "###########################################################"
echo "Finished at: "`date`
echo "###########################################################"
exit 0
