# OvaMap

The aim is to create count data as input to this script: https://github.com/lsteuernagel/hypoMap_datasets/blob/main/R/raw_hypoMap_datasets.R

SRA fastq files were downloaded for six 10Xgenomics datasets: 
- PRJNA766716
- PRJNA836755
- PRJNA792835
- PRJNA754050
- PRJNA879764
- PRJNA849410

### 1. Download the SRA data and metadata: extract_SRA_data.md. 
 - Use [extract_SRA_data.md](https://github.com/melparker101/OvaMap/blob/main/prepare_datasets/SRA/extract_SRA_data.md) to extract the SRA data from relevant runs
 - prefetch SRA files: no slurm script as this required internet connection. Run in parallel as this takes a while.
 - convert to fastq using fasterq-dump: fasterq-dump.sh
 - compress files: compress_fastq_files.sh
### 2. Rename files ready for cellranger: cellranger.md (redo this script)
### 3. Run cell ranger
 - download reference: download_cellrange_ref.sh
 - run cell ranger nested array scripts to run all runs from all projects in parallel: cell_ranger.sh
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
- 






