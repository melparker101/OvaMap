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
