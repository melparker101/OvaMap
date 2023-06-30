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

# Add this line to ~/.bash_profile
export SINGULARITY_CACHEDIR=/well/lindgren/users/mzf347/singularity/cache

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
Follow the hypoMap pipeline for [Prepare datasets](https://github.com/lsteuernagel/hypoMap_datasets) with the six Group 1 datasets below. 

- Xu10X
- Jin10X
- Guahmich10X
- LaFargue10X
- Fonseca10X
- Choi10X

The process for downloading the data is as follows (For more information see the [G1/README.md](https://github.com/melparker101/OvaMap/tree/main/prepare_datasets/G1) file):

1. Download the SRA data and metadata
2. Rename files ready for cellranger
3. Run cell ranger
4. Move cell ranger files and SRA tables to ovaMap directory
5. Create Seurat objects using cellranger output counts and metadata

Once the data is all downloaded, processed with CellRanger and organised into the relevant directories, use the [execute_hypoMap_datasets.R](https://github.com/lsteuernagel/hypoMap_datasets/blob/main/R/execute_hypoMap_datasets.R) hypoMap script. Info from their github:

Execute processing pipeline
The core script to execute the slurm jobs is "R/execute_hypoMap_datasets.R" which consists of 4 steps:

1. Load input data overview and parameters
2. Preprocessing
3. Doublet-detection
4. Merging


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

Once we completed these steps, we need to merge the count and metadata together in a Seurat object. We can do this using an edited version of the hypoMap script [raw_hypoMap_datasets.R](https://github.com/lsteuernagel/hypoMap_datasets/blob/main/R/raw_hypoMap_datasets.R). The ovaMap edited script is: [edited_hypomap_scripts](https://github.com/melparker101/OvaMap/blob/main/edited_hypomap_scripts/raw_hypoMap_datasets.R). This script does not use the docker/singularity image.

Each dataset will then have a Seurat object. For example, the 10Genomics Choi et al. dataset will have the Seurat object
`//well/lindgren/users/mzf347/ovaMap/data/ovaMap_rawdata/Choi10X/Choi10X_seurat_raw.rds`.

We can now proceed with the hypoMap processing pipeline...

### Edit and use the hypoMap datasets pipeline
Copy and edit the [execute_hypoMap_datasets.R](https://github.com/lsteuernagel/hypoMap_datasets/blob/main/R/execute_hypoMap_datasets.R). 

Change:
- singularity_path to `//well/lindgren/users/mzf347/singularity/r_scvi_docker_v2_v9.sif`.
- `param_path = //well/lindgren/users/mzf347/ovaMap/slurm/ovaMap_v2_params/` - where to store temporary json's with params for jobs:
- `log_path = //well/lindgren/users/mzf347/ovaMap/slurm/ovaMap_v2_slurmlogs/` - where to save log files --> use this path in the slurm.sh files!
- This script sources a "R/functions.R" file containing the functions that are required.
- Dataset names
- Go through the script and find anything else that needs changing!

## 3. Add in the other datasets
Group 2 datasets do not have SRA paired read fastq files and SRA metadata availible. However, they could be good datasets to add in! More information in the [G2/README.md file](https://github.com/melparker101/OvaMap/tree/main/prepare_datasets/G2). I haven't started working on these yet, but the markdown file has information on where to get the data from.

- Fan10X
- Wagner10X
- Lengyel10X
- LengyelDropSeq

