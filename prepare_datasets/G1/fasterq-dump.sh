#!/bin/bash

# ----------------------------------------------------------
# Script to convert SRA files to fastq files
# melodyjparker14@gmail.com - Mar 23
# Not tested since updated
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

IN=sra_files  # $1
OUT=raw_reads  # $2

# Load modules
module load SRA-Toolkit/3.0.0-centos_linux64
module load parallel/20210722-GCCcore-11.2.0

cd "$PROJECT"

# Create output directory
if [ ! -p "$OUT" ]
then
  mkdir -p "OUT"
fi

# Convert SRA files to fastq files
# Include technical reads because cell ranger takes R1 and R2 as input and some runs only have R2 saved as a biological read in SRA
# S for split?
cat "$PROJECT"_SraAccList.txt | parallel fasterq-dump "$IN"/{} --include-technical -S -O "$OUT"


echo "###########################################################"
echo "Fastq files created."
echo "Finished at: "`date`
echo "###########################################################"
exit 0
