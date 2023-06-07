#!/bin/bash

# ----------------------------------------------------------
# Script to run cell ranger count pipeline
# melodyjparker14@gmail.com - Mar 23
# ----------------------------------------------------------

#SBATCH -A lindgren.prj
#SBATCH -p short
#SBATCH -c 5
#SBATCH -J cell_ranger_count
#SBATCH -o logs/cr_output.out
#SBATCH -e logs/cr_error.err

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

PROJECT=PRJNA879764
REF=refdata-gex-GRCh38-2020-A
FASTQ=raw_reads3

cellranger count --id run_count_"$PROJECT" \
                 --transcriptome "$REF" \
                 --fastqs "$PROJECT"/"$FASTQ" \
                 
echo "###########################################################"
echo "Finished at: "`date`
echo "###########################################################"
exit 0                 
