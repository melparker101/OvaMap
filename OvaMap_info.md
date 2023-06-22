# OvaMap Tutorial
We want to use the hypoMap pipelines on our own ovary data. They use docker and slurm (we can use singularity on BMRC). The hypoMap pipeline is split into three parts:

1. [Prepare datasets](https://github.com/lsteuernagel/hypoMap_datasets) - downloading fastq files and SRA metadata, producing count matrices, and then creating Seurat objects from these.
2. [scIntegration](https://github.com/lsteuernagel/scIntegration) - finding optimal hyperparameters for scVI to integrate datasets.
3. [scHarmonization](https://github.com/lsteuernagel/scHarmonization) - harmonising annotations for the integrated single cell dataset.

## 1. Download docker image
