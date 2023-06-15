# OvaMap

The aim is to create count data as input to this script: https://github.com/lsteuernagel/hypoMap_datasets/blob/main/R/raw_hypoMap_datasets.R

### Group 1 datasets 
SRA fastq files were downloaded for six 10Xgenomics datasets: 

| Project acc.  | Dataset Name | Paper URL | Number of Samples | Number of runs   | Number of cells | Number of cell types |
| :-----------: |:------------:|:---------:|:-----------------:|:----------------:|:---------------:|:--------------------:|
| PRJNA766716   | Xu10X        | [www.ncbi.nlm.nih.gov](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9662915/)          | 5                 | 20               | 26,060          |                      |
| PRJNA836755   | Jin10X       | [www.biorxiv.org](https://www.biorxiv.org/content/biorxiv/early/2022/05/19/2022.05.18.492547.full.pdf)          | 8                 | 8                | 42,568          | 8                    |
| PRJNA792835   | Guahmich10X  |           | 9                 | 10               | 48,147          | 22, 6                |
| PRJNA754050   | Sood10X      |           | 1                 | 1                |                 | 6                    |
| PRJNA879764   | Fonseca10X   |           | 4                 | 11               | 22,219          | 9                    |
| PRJNA849410   | Choi10X      |           | 4                 | 8                | 7609            | 18, 13               |


### 1. Download the SRA data and metadata: extract_SRA_data.md. 
 - Use [extract_SRA_data.md](https://github.com/melparker101/OvaMap/blob/main/prepare_datasets/SRA/extract_SRA_data.md) to extract the SRA data from relevant runs
 - first, download the SRA metadata tables. Download the metadata tables officially using EDirect software from NCBI to use later, but also download tables using pysradb to obtain extra metadata columns required for filtering.
 - prefetch SRA files. Run in rescomp as internet connection is required. Run in parallel as this takes a while.
 - convert to fastq using fasterq-dump: fasterq-dump.sh. Make sure the files are split into forward and reverse strands because cellranger requires this as input! Also make sure to include technical reads as some projects deposit some of the reads we need as technical.
 - format the SRA tables into proper columns. Use this script: [format_SRA_tables.R](https://github.com/melparker101/OvaMap/blob/main/prepare_datasets/SRA/format_SRA_tables.R)
 - compress files: [compress_fastq_files.sh](https://github.com/melparker101/OvaMap/blob/main/prepare_datasets/SRA/compress_fastq_files.sh). Although fastq-dump has a compression flag, fasterq does not - do this manually afterwards.
### 2. Rename files ready for cellranger
 - Use [rename_fastq_files.sh](https://github.com/melparker101/OvaMap/blob/main/prepare_datasets/SRA/rename_fastq_files.sh). Different runs have different length reads. Some runs split the reads into 2 (R1,R2), some into 3 (I1), and some into 4 (I2). This script accounts for these.
### 3. Run cell ranger
 - download reference for cellranger: [download_cellrange_ref.sh](https://github.com/melparker101/OvaMap/blob/main/prepare_datasets/SRA/download_cellrange_ref.sh)
 - run cell ranger nested array scripts to run all runs from all projects in parallel: [cellranger.sh](https://github.com/melparker101/OvaMap/blob/main/prepare_datasets/SRA/cellranger.sh)
 - The output files for run SRR15424680 will be in the directory below
```bash
cellranger_count/run_count_SRR15424680/outs/
```

Check that all output dirs were created:
```bash
projects=("PRJNA766716" "PRJNA836755" "PRJNA792835" "PRJNA754050" "PRJNA879764" "PRJNA849410")
datasets=("Xu10X" "Jin10X" "Guahmich10X" "Sood10X" "Fonseca10X" "Choi10X")
  
# Loop through each project and copy the count matrix
for ((i=0; i<${#projects[@]}; i++))
do
    project=${projects[i]}
    datasets=${datasets[i]}
    
    # Check if the project directory exists
        # Get the list of runs from the SraAccList.txt file
        runs=$(cat $project/${project}_SraAccList.txt)
  
  for run in $runs
        do
            echo $run
            OUTS="cellranger_count/run_count_$run/outs/"
            echo $OUTS
            ls $OUTS
            echo ""  
    done
done
```
Check the runs that failed, e.g.: 
```bash
cat //well/lindgren/users/mzf347/ovaMap/fastq/cellranger_count/run_count_SRR17351745/_log
```
### 4. Move cell ranger files and SRA tables to ovaMap directory
- [move_and_rename_SRAtables.md](https://github.com/melparker101/OvaMap/blob/main/prepare_datasets/SRA/move_and_rename_SRAtables.md)






