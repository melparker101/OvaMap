# 1. Set up
Collect together a list of accession numbers for all of the projects where SRA data is availible for download.
```text
PRJNA766716
PRJNA836755
PRJNA701233
PRJNA792835
PRJNA754050
PRJNA421274
PRJNA484542
PRJNA514416
PRJNA189204
PRJNA552816
PRJNA153427
PRJNA879764
PRJNA849410
PRJNA774191
PRJNA647391

```

Add these to a text file. Leave an empty line at the bottom.
```bash
cd "$MYDIR"/ovaMap/fastq

cat > prja_list.txt
# Insert list of accession numbers for projects availible on SRA
```

Make a directory for each project accession number.
```bash
while read p; do mkdir "$p"; done < prja_list.txt
```

# 2. Download metadata file for each project accession
Install EDirect software from NCBI.
```bash
cd ~

# This downloads into homefile automatically
sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"

# Move it to software directory
mv edirect "$MYDIR"/software/
```

Add the following line to .bashrc.
```bash
export PATH=${PATH}:"$MYDIR"/software/edirect
```

Get metadata for each entry.
```bash
cd "$MYDIR"/ovaMap/fastq

for p in P*
do esearch -db sra -query "$p" | efetch -format runinfo > "$p"/"$p"_SraRunTable.txt
done 
```

Check that this has worked.
```bash
tree .
```

The output should look like this:
```bash
|-- PRJNA153427
|   `-- PRJNA153427_SraRunTable.txt
|-- PRJNA189204
|   `-- PRJNA189204_SraRunTable.txt
|-- PRJNA315404
|   `-- PRJNA315404_SraRunTable.txt
|-- PRJNA340388
|   `-- PRJNA340388_SraRunTable.txt
|-- PRJNA421274
|   `-- PRJNA421274_SraRunTable.txt
|-- PRJNA484542
|   `-- PRJNA484542_SraRunTable.txt
|-- PRJNA514416
|   `-- PRJNA514416_SraRunTable.txt
|-- PRJNA552816
|   `-- PRJNA552816_SraRunTable.txt
|-- PRJNA647391
|   `-- PRJNA647391_SraRunTable.txt
|-- PRJNA701233
|   `-- PRJNA701233_SraRunTable.txt
|-- PRJNA754050
|   `-- PRJNA754050_SraRunTable.txt
|-- PRJNA766716
|   `-- PRJNA766716_SraRunTable.txt
|-- PRJNA774191
|   `-- PRJNA774191_SraRunTable.txt
|-- PRJNA792835
|   `-- PRJNA792835_SraRunTable.txt
|-- PRJNA836755
|   `-- PRJNA836755_SraRunTable.txt
|-- PRJNA849410
|   `-- PRJNA849410_SraRunTable.txt
|-- PRJNA879764
|   `-- PRJNA879764_SraRunTable.txt
`-- prja_list.txt
```

# 3. Manually filter metadata tables to only contain samples/runs that we want
The SRA Run tables we downloaded do not contain the 'tissue_type' column from the metadata table on the SRA website. There are a few ways to extract the extra data using the command line see [https://bioinformatics.stackexchange.com/questions/7027/how-to-extract-metadata-from-ncbis-short-read-archive-sra-for-a-few-runs](link). I found the easiest way was to use the package pysradb. Save the data in a tsv file to avoid formatting issues. Use the detailed arguement to ensure metadata for all runs are downloaded.

| Project acc.  | Filtering Required? | Filtering requirements    | Total runs after filtering |
| :-----------: |:-------------------:| :------------------------:|:--------------------------:|
| PRJNA766716   | Y                   | Disgard cancer samples    | 20                         | .
| PRJNA836755   | Y                   | Disgard snATAC runs       | 8                          | .
| PRJNA701233   | N                   | NA                        | 19                         | .
| PRJNA792835   | Y                   | Disgard scATAC runs       | 10                         | .
| PRJNA754050   | Y                   | Disgard cancer samples    | 1                          | .
| PRJNA421274   | N                   | NA                        | 148                        | .
| PRJNA484542   | N                   | NA                        | 31                         | .
| PRJNA514416   | N                   | No for now (endometriosis)| 34                         | .
| PRJNA189204   | Y                   | Filter for human oocytes  | 3                          | .
| PRJNA552816   | Y                   | Filter for oocytes        | 9                          | .
| PRJNA153427   | Y                   | Filter for oocytes        | 3                          | .
| PRJNA879764   | Y                   | Filter for ovary          | 11                         | .
| PRJNA849410   | N                   | NA                        | 8                          | .
| PRJNA774191   | N                   | NA                        | 141                        | .
| PRJNA647391   | Y                   | Filter for RNA-seq only   | 42                         | -


### PRJNA766716

```bash
# pip install pysradb

cd PRJNA766716
pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv
```
Filter for PRJNA766716 to exclude cancer samples:

```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
pysradb_table = data.table::fread(paste0(prjna,"_PysradbTable.tsv"),data.table = F)
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Replace spaces with underscores in colnames of pysradb table
colnames(pysradb_table) <- sub(" ", "_", colnames(pysradb_table))

# Extract run accession numbers for normal samples only (not cancer) and filter using these
run_acc <- pysradb_table[pysradb_table$tissue_type %like% "Normal", "run_accession"]
sra_table <- filter(sra_table, Run %in% run_acc)

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```

### PRJNA836755
Go to the project directory and load R
```bash
cd ../PRJNA836755
```
Again, filter in R:
```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Filter table so that it only includes RNA-seq runs
sra_table <- sra_table[sra_table$LibraryStrategy == "RNA-Seq",]

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```
### PRJNA792835
Disgard scATAC runs.

```bash
cd ../	PRJNA792835
R
```

```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Filter table so that it only includes RNA-seq runs
sra_table <- sra_table[sra_table$LibraryStrategy != "ATAC-seq",]

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```

### PRJNA754050
There is only one run for non-cancerous cells: SRR15424680. We could use sed to filter for this, but we already have R code so use this.
```bash
cd ../	PRJNA754050
```
Run R
```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Filter table so that it only includes RNA-seq runs
sra_table <- sra_table[sra_table$Run == "SRR15424680",]

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```

### PRJNA189204
These samples contain both human and mouse and a variety of different cells types (most of which are embryos). 
```bash
cd ../	PRJNA189204
pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv
```
Filter for human and oocytes:
```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
pysradb_table = data.table::fread(paste0(prjna,"_PysradbTable.tsv"),data.table = F)
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Replace spaces with underscores in colnames of pysradb table
colnames(pysradb_table) <- sub(" ", "_", colnames(pysradb_table))

# Filter table so that it only includes human samples that are oocytes
run_acc <- pysradb_table[(pysradb_table$cell_type == "oocyte" & pysradb_table$organism_name == "Homo sapiens"), "run_accession"]
sra_table <- filter(sra_table, Run %in% run_acc)

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```

### PRJNA552816
Filter for oocytes.

```bash
cd ../PRJNA552816
pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv
```
```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
pysradb_table = data.table::fread(paste0(prjna,"_PysradbTable.tsv"),data.table = F)
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Replace spaces with underscores in colnames of pysradb table
colnames(pysradb_table) <- sub(" ", "_", colnames(pysradb_table))

# Filter table so that it only includes human samples that are oocytes
run_acc <- pysradb_table[(pysradb_table$embryo_type == "Oocyte"), "run_accession"]
sra_table <- filter(sra_table, Run %in% run_acc)

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```

### PRJNA153427
```bash
cd ../PRJNA153427
pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv
```
```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
pysradb_table = data.table::fread(paste0(prjna,"_PysradbTable.tsv"),data.table = F)
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Replace spaces with underscores in colnames of pysradb table
colnames(pysradb_table) <- sub(" ", "_", colnames(pysradb_table))

# Filter table so that it only includes oocytes
run_acc <- pysradb_table[(pysradb_table$cell_type %like% "Oocyte"), "run_accession"]
sra_table <- filter(sra_table, Run %in% run_acc)

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```


### PRJNA879764
```bash
cd ../PRJNA879764
pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv
```

```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
pysradb_table = data.table::fread(paste0(prjna,"_PysradbTable.tsv"),data.table = F)
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Replace spaces with underscores in colnames of pysradb table
colnames(pysradb_table) <- sub(" ", "_", colnames(pysradb_table))

# Filter table so that it only includes oocytes
run_acc <- pysradb_table[(pysradb_table$tissue %like% "Ovary"), "run_accession"]
sra_table <- filter(sra_table, Run %in% run_acc)

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```

### PRJNA647391
```bash
cd ../PRJNA647391
```

```R
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Read in data
sra_table = data.table::fread(paste0(prjna,"_SraRunTable.txt"),data.table = F)

# Filter table so that it only includes RNA-seq
sra_table <- sra_table[sra_table$LibraryStrategy %like% "RNA",]

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```
