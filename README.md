# OvaMap

- **Aim:** to integrate single-cell RNA ovary datasets to build a transcriptomic ovary reference atlas. 
- **Objective:** follow the methods used in [hypoMap](https://www.nature.com/articles/s42255-022-00657-y) using online and in-house ovary datasets. 

The hypoMap pipeline is split into three parts:
1. [Prepare datasets](https://github.com/lsteuernagel/hypoMap_datasets) - downloading fastq files and SRA metadata, producing count matrices, and then creating Seurat objects from these.
2. [scIntegration](https://github.com/lsteuernagel/scIntegration) - finding optimal hyperparameters for scVI to integrate datasets.
3. [scHarmonization](https://github.com/lsteuernagel/scHarmonization) - harmonising annotations for the integrated single cell dataset.

