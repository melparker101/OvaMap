# OvaMap

SRA fastq files were downloaded for six 10Xgenomics datasets: PRJNA766716, PRJNA836755, PRJNA792835, PRJNA754050, PRJNA879764, PRJNA849410.

1. Download the SRA data and metadata: extract_SRA_data.md. 
 - prefetch SRA files: no slurm script as this required internet connection. Run in parallel. (write a small script)
 - convert to fastq using fasterq-dump: fasterq-dump.sh
 - compress files: compress_fastq_files.sh
2. Rename files ready for cellranger: cellranger.md (redo this script)
4. Run cell ranger
 - download reference: download_cellrange_ref.sh
 - run cell ranger array scripts: cell_ranger.sh

The aim is to create count data as input to this script: https://github.com/lsteuernagel/hypoMap_datasets/blob/main/R/raw_hypoMap_datasets.R
