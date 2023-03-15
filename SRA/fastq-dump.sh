#!/bin/bash

# ----------------------------------------------------------
# Script to convert SRA files to fastq files. Testing on PRJNA836755 
# melodyjparker14@gmail.com - Mar 23
# ----------------------------------------------------------

#SBATCH -A lindgren.prj
#SBATCH -p short
#SBATCH -c 6
#SBATCH -J fastq-dump
#SBATCH -o logs/fastq-dump.out
#SBATCH -e logs/fastq-dump.err
#SBATCH -a 1-8

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


# PROJECT=$(sed "${SLURM_ARRAY_TASK_ID}"'q;d' prja_list.txt)
READ=$(sed "${SLURM_ARRAY_TASK_ID}"'q;d' PRJNA836755_SraAccList.txt)

IN=sra_files  # $1
OUT=fqd_raw_reads  # $2

# Load modules
module load SRA-Toolkit/3.0.0-centos_linux64
module load parallel/20210722-GCCcore-11.2.0

# Create output directory
if [ ! -p "$OUT" ]
then
  mkdir -p "OUT"
fi

# Convert SRA files to fastq files
fastq-dump "$IN"/"$READ" --outdir "$OUT" --skip-technical --split-3 --origfmt --gzip


echo "###########################################################"
echo "Fastq files created."
echo "Finished at: "`date`
echo "###########################################################"
exit 0
