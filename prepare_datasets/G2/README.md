| Dataset Name   | Year | Dataset Acc.    | BioProject                                                         | SRA Study                                                              | No. of Samples | Number of Cells | Number of cell types |
| -------------- | ---- | --------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------------- | -------------- | --------------- | -------------------- |
| Fan10X         | 2019 | GSE118127       | [PRJNA484542](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA484542) | [SRP156350](https://trace.ncbi.nlm.nih.gov/Traces/sra?study=SRP156350) | 31             | 20,676          | 19                   |
| Wagner10X      | 2020 | E-MTAB-8381     | PRJEB34869                                                         | \-                                                                     | 4              | 12,160          | 6                    |
| Lengyel10X     | 2022 | EGAS00001006780 | \-                                                                 | \-                                                                     | 4              | 22,332          | 6                    |
| LengyelDropSeq | 2022 | \-              | \-                                                                 | \-                                                                     | 2              | 3,802   | 6 |  

# Group 2
These are datasets where paired fastq reads are not readily availible, but other formats are that we can use.

- Fan10X dataset has fastq files availible, but they
- Wagner10X has fastq files availible from ENI rather than SRA. These can be processed in a similar manner to the group 1 datasets, but the metadata will need curating manually.
- For Lengyel10X and LengyelDropSeq, the raw fastq data is still not availible, but keep checking [EGA](https://ega-archive.org/datasets/EGAD00001010076) in case they add it. Instead, we can download the processed RDS or H5AD file from [cellxgene](https://cellxgene.cziscience.com/collections/d36ca85c-3e8b-444c-ba3e-a645040c6185) - this contains both the 10X and dropseq data lumped together. We can load this into a Seurats object and then filter to separate them into 2 datasets. Metadata will need adjusting manually. Use [cellxgene explorer](https://cellxgene.cziscience.com/e/d1207c81-7309-43a7-a5a0-f4283670b62b.cxg/) to visualise which samples come from which donors and techniques, etc.
