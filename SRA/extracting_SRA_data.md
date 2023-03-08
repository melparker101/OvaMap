### 1. Set up
Collect together a list of accession numbers for all of the projects where SRA data is availible for download.
```text
PRJNA836755
PRJNA701233
PRJNA792835
PRJNA754050
PRJNA340388
PRJNA421274
PRJNA484542
PRJNA315404
PRJNA514416
PRJNA189204
PRJNA552816
PRJNA153427
PRJNA879764
PRJNA849410
PRJNA774191
PRJNA647391
PRJNA766716
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

### 2. Download metadata file for each project accession
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
The SRA Run tables we downloaded do not contain the 'tissue_type' column from the metadata table on the SRA website. There are a few ways to extract the extra data using the command line see [https://bioinformatics.stackexchange.com/questions/7027/how-to-extract-metadata-from-ncbis-short-read-archive-sra-for-a-few-runs](link). I found the easiest way was to use the package pysradb. Save the data in a tsv file to avoid formatting issues.
```bash
# pip install pysradb

pysradb metadata PRJNA766716 --saveto PRJNA766716_PysradbTable.tsv
```
Filter for RJNA766716 to exclude cancer samples:

```R
library(data.table)
library(dplyr)

# Read in data
pysradb_table = data.table::fread(paste0("PRJNA766716_PysradbTable.tsv"),data.table = F)
sra_table = data.table::fread(paste0("PRJNA766716_SraRunTable.txt"),data.table = F)

# Replace spaces with underscores in colnames of pysradb table
colnames(pysradb_table) <- sub(" ", "_", colnames(pysradb_table))

# Extract run accession numbers for normal samples only (not cancer) and filter using these
run_acc <- pysradb_table[pysradb_table$tissue_type %like% "Normal", "run_accession"]
sra_table <- filter(sra_table, Run %in% run_acc)

# Write to file, replacing the original
write.table(sra_table, file='PRJNA766716_SraRunTable.txt', quote=FALSE, sep='\t')
```
