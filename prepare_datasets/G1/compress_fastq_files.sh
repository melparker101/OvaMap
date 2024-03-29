#!/bin/bash

# ----------------------------------------------------------
# Array script to compress fastq files
# melodyjparker14@gmail.com - Mar 23
# ----------------------------------------------------------

#SBATCH -A lindgren.prj
#SBATCH -p short
#SBATCH -c 5
#SBATCH -J gzip_fastq_files
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

# IN=$PWD

# Load modules
module load SRA-Toolkit/3.0.0-centos_linux64
module load parallel/20210722-GCCcore-11.2.0

# Convert SRA files to fastq files
cat "$PROJECT"/"$PROJECT"_SraAccList.txt | parallel gzip "$PROJECT"/raw_reads/{}*.fastq


echo "###########################################################"
echo "Finished at: "`date`
echo "###########################################################"
exit 0
