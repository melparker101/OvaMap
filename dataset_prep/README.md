# Dataset Preparation
Datasets were curated: [Ovaries dataset spreadsheet](https://docs.google.com/spreadsheets/d/1NVvpP0_stbEctTSCzAP7E7L0-xED6YaDVt1cIQiIbXU/edit#gid=0).

Ovary dataset criterea for choosing the first set of datasets:
- single cell or single nuclei ovary RNA-seq data
- non-cancerous
- healthy cells, e.g. not endometriosis (we can play around with this later)
- \>1000 cells (other datasets with a smaller number of cells can be added later, especially oocytes) 
- Droplet-based method (only droplet-based was used in hypoMap)
- 10X Genomics (to set up cellranger pipeline)
- Non-fetal ovary cells (this can be extended later)
- No embryos
- SRA fastq and SRA metadata availible (the hypoMap datasets pipeline takes SRA fastq files and metadata as input)

OvaMap can be extended to include other datasets once the main ovaMap pipeline is set up. Any datasets where Seurat objects can be directly created from will be relatively easy to add (i.e. RDS/H5AD files, or sets of matrix.mtx,features.tsv and barcodes.tsv), though metadata will need to be inputted manually, which could be time consuming. If fastq files are not availible, but BAM are, it would be more consistent convert the BAM back to fastq and realign with the cellranger count pipeline for 10X genomics datasets (which uses STAR) or STAR for other datasets, e.g. dropseq datasets. This could be tested with one dataset with availible BAM and counts to see if there is any improvement with scVI when adding the dataset counts in directly vs adding the counts created from reverting back to fastq first.

See the [SRA](https://github.com/melparker101/OvaMap/tree/main/dataset_prep/SRA) subdirectory for the first set of datasets to be used for the ovaMap pipeline, and the methods used to process these.

