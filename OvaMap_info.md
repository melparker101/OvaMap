# OvaMap Tutorial
We want to use the hypoMap pipelines on our own ovary data. They use docker and slurm (we can use singularity on BMRC). The hypoMap pipeline is split into three parts:

1. [Prepare datasets](https://github.com/lsteuernagel/hypoMap_datasets) - downloading fastq files and SRA metadata, producing count matrices, and then creating Seurat objects from these.
2. [scIntegration](https://github.com/lsteuernagel/scIntegration) - finding optimal hyperparameters for scVI to integrate datasets.
3. [scHarmonization](https://github.com/lsteuernagel/scHarmonization) - harmonising annotations for the integrated single cell dataset.

## 1. Download docker image
```bash
# Make a directory to keep singularity images in
mkdir //well/lindgren/users/mzf347/singularity
cd //well/lindgren/users/mzf347/singularity

# This is the docker image recommended
# It is fixed so is an older version of R
singularity pull docker://lsteuernagel/r_scvi_docker_v2:v9

# Make a simple R test script in home dir
singularity exec r_scvi_v11.sif Rscript R_test.sh
# This works
```

In their scripts they use the following command to run docker:
```bash
srun singularity exec $singularity_image Rscript $method_script $param_file
```

When singularity is run, you will only have access to the directory it is run in. To access other directories too you need to add an argument.
See this [singularity](https://carpentries-incubator.github.io/singularity-introduction/04-singularity-files/index.html) tutorial for more info.
"The -B option to the singularity command is used to specify additonal binds".

```bash
# Add a shell variable to ~/.bashrc for the singularity directory
SIF=//well/lindgren/users/mzf347/singularity

# Run this from the ovaMap directory. The R_test.sh script should be contained here
# Use the -B argument to bind the pwd to the container
singularity exec \
-B "$(pwd)":"$(pwd)" \
"$SIF"/r_scvi_docker_v2_v9.sif \
Rscript R_test.sh

# Have a look in the shell
singularity shell \
-B "$(pwd)":"$(pwd)" \
"$SIF"/r_scvi_docker_v2_v9.sif

# List the availible directories
ls

# Exit the shell
exit
```

## 2. Start with a subset of datasets that we can follow the hypoMap dataset pipeline with
Start with the [Group 1](https://github.com/melparker101/OvaMap/tree/main/prepare_datasets/G1) set of datasets. These are appropriate datasets where R1 and R2 fastq files and SRA metadata tables can be downloaded from SRA.

### Prepare datasets
Follow the hypoMap pipeline for [Prepare datasets](https://github.com/lsteuernagel/hypoMap_datasets) with these six Group 1 datasets. 
Once the data is all downloaded, processed with CellRanger and organised into the relevant directories, try to use the [execute_hypoMap_datasets.R](https://github.com/lsteuernagel/hypoMap_datasets/blob/main/R/execute_hypoMap_datasets.R) hypoMap script. Info from their github:

```
Execute processing pipeline
The core script to execute the slurm jobs is "R/execute_hypoMap_datasets.R" which consists of 4 steps:

Load input data overview and parameters
Preprocessing
Doublet-detection
Merging
```

1. Prepare raw data
Create a directory to store all of the raw ovary data in (Seurat objects (.rds) and SRA  metadata (.txt)). This directory will contain a subdirectory for each dataset and an 'SRAtables' directory containing all of their metadata tables.

```bash
# The path that hypoMap uses is /beegfs/scratch/bruening_scratch/lsteuernagel/data/hypoMap_rawdata/
mkdir //well/lindgren/users/mzf347/ovaMap/data/ovaMap_rawdata
```
Follow the workflow described in [https://github.com/melparker101/OvaMap/tree/main/prepare_datasets/G1](Group 1) to:
- Choose the first set of datasets
- Download metadata and filter samples
- Download fastq files and SRA table for the runs we want to use
- Rename the fastq files ready for CellRanger
- Run the CellRanger pipeline on fastq files to create output directories per run (including the raw counts)
- Move over the CellRanger output and SRA tables to our ovaMap_rawdata directory 

Once we completed these steps, we need to merge the count and metadata together in a Seurat object. We can do this using an edited version of the hypoMap script [raw_hypoMap_datasets.R](https://github.com/lsteuernagel/hypoMap_datasets/blob/main/R/raw_hypoMap_datasets.R). The ovaMap edited script is: [edited_hypomap_scripts](https://github.com/melparker101/OvaMap/blob/main/edited_hypomap_scripts/raw_hypoMap_datasets.R).

We will then have the following **ovaMap_rawdata** directory layout:
```bash
$ pwd
//well/lindgren/users/mzf347/ovaMap/data/ovaMap_rawdata

$ tree -L 2 .
.
|-- Choi10X
|   |-- run_count_SRR19660773
|   |-- run_count_SRR19660774
|   |-- run_count_SRR19660775
|   |-- run_count_SRR19660776
|   |-- run_count_SRR19660777
|   |-- run_count_SRR19660778
|   |-- run_count_SRR19660779
|   `-- run_count_SRR19660780
|-- Fonseca10X
|   |-- run_count_SRR21536711
|   |-- run_count_SRR21536712
|   |-- run_count_SRR21536716
|   |-- run_count_SRR21536717
|   |-- run_count_SRR21536727
|   |-- run_count_SRR21536728
|   |-- run_count_SRR21536765
|   |-- run_count_SRR21536766
|   |-- run_count_SRR21536767
|   |-- run_count_SRR21536768
|   `-- run_count_SRR21536769
|-- Guahmich10X
|   |-- run_count_SRR17351745
|   |-- run_count_SRR17351746
|   |-- run_count_SRR17351750
|   |-- run_count_SRR17351751
|   |-- run_count_SRR17351752
|   |-- run_count_SRR17351753
|   |-- run_count_SRR17351754
|   |-- run_count_SRR19614723
|   |-- run_count_SRR19614728
|   `-- run_count_SRR19614729
|-- Jin10X
|   |-- run_count_SRR19153925
|   |-- run_count_SRR19153926
|   |-- run_count_SRR19153927
|   |-- run_count_SRR19153928
|   |-- run_count_SRR19153929
|   |-- run_count_SRR19153930
|   |-- run_count_SRR19153931
|   `-- run_count_SRR19153932
|-- SRAtables
|   |-- SraRunTable_Choi10X.txt
|   |-- SraRunTable_Fonseca10X.txt
|   |-- SraRunTable_Guahmich10X.txt
|   |-- SraRunTable_Jin10X.txt
|   |-- SraRunTable_Sood10X.txt
|   `-- SraRunTable_Xu10X.txt
|-- Sood10X
|   `-- run_count_SRR15424680
`-- Xu10X
    |-- run_count_SRR16093329
    |-- run_count_SRR16093330
    |-- run_count_SRR16093331
    |-- run_count_SRR16093332
    |-- run_count_SRR16093333
    |-- run_count_SRR16093334
    |-- run_count_SRR16093335
    |-- run_count_SRR16093336
    |-- run_count_SRR16093337
    |-- run_count_SRR16093338
    |-- run_count_SRR16093339
    |-- run_count_SRR16093340
    |-- run_count_SRR16093341
    |-- run_count_SRR16093342
    |-- run_count_SRR16093343
    |-- run_count_SRR16093344
    |-- run_count_SRR16093345
    |-- run_count_SRR16093346
    |-- run_count_SRR16093347
    `-- run_count_SRR16093348

65 directories, 6 files
```
