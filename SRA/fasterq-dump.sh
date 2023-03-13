#!/bin/bash

# ----------------------------------------------------------
# Script to convert SRA files to fastq files
# melodyjparker14@gmail.com - Dec 22
# ----------------------------------------------------------

#SBATCH -A lindgren.prj
#SBATCH -p short
#SBATCH -c 5
#SBATCH -J fasterq-dump
#SBATCH -o logs/output.out
#SBATCH -e logs/error.err
#SBATCH -a 1-15

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


PROJECT=$(sed "${SLURM_ARRAY_TASK_ID}"'q;d' prja_list.txt)

IN="$PROJECT"/sra_files  # $1
OUT="$PROJECT"/raw_reads  # $2

# Load modules
module load SRA-Toolkit/3.0.0-centos_linux64
module load parallel/20210722-GCCcore-11.2.0

# Convert SRA files to fastq files
cat "$PROJECT"/"$PROJECT"_SraAccList.txt | parallel fasterq-dump "$IN"/{} -O "$OUT"


echo "###########################################################"
echo "Fastq files created."
echo "Finished at: "`date`
echo "###########################################################"
exit 0
