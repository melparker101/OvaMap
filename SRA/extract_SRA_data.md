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
| PRJNA766716   | Y                   | Disgard cancer samples    | 20                         | 
| PRJNA836755   | Y                   | Disgard snATAC runs       | 8                          | 
| PRJNA701233   | N                   | NA                        | 19                         | 
| PRJNA792835   | Y                   | Disgard scATAC runs       | 10                         | 
| PRJNA754050   | Y                   | Disgard cancer samples    | 1                          | 
| PRJNA421274   | N                   | NA                        | 148                        | 
| PRJNA484542   | N                   | NA                        | 31                         | 
| PRJNA514416   | N                   | No for now (endometriosis)| 34                         | 
| PRJNA189204   | Y                   | Filter for human oocytes  | 3                          | 
| PRJNA552816   | Y                   | Filter for oocytes        | 9                          | 
| PRJNA153427   | Y                   | Filter for oocytes        | 3                          | 
| PRJNA879764   | Y                   | Filter for ovary          | 11                         | 
| PRJNA849410   | N                   | NA                        | 8                          | 
| PRJNA774191   | N                   | NA                        | 141                        | 
| PRJNA647391   | Y                   | Filter for RNA-seq only   | 42                         | 

Make sure that pusradb is installed - we will use this package for downloading extra metadata for selected projects.
```bash
pip install pysradb
```

### PRJNA766716
Filter for PRJNA766716 to exclude runs for cancer samples.
```bash
cd PRJNA766716
```
```R
#############
R Script
#############
library(data.table)
library(dplyr)

# Download pysradb metadata
system('pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv')

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

# Remove first column so that the new first column contains the run accession numbers
sra_table <- sra_table[,-1]

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna,"_SraRunTable.txt"), sep='\t')
```

### PRJNA836755
Go to the project directory and load R.
```bash
cd ../PRJNA836755
```
```R
#############
R Script
#############
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
cd ../PRJNA792835
```
```R
#############
R Script
#############
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
cd ../PRJNA754050
```
```R
#############
R Script
#############
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
These samples contain both human and mouse and a variety of different cells types (most of which are embryos). Filter for human and oocytes.
```bash
cd ../PRJNA189204
```
```R
#############
R Script
#############
library(data.table)
library(dplyr)

# Download pysradb metadata
system('pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv')

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
```
```R
#############
R Script
#############
library(data.table)
library(dplyr)

# Extract project name from directory name
fullpath = getwd()
prjna = basename(fullpath)

# Download pysradb metadata
system('pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv')

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
```
```R
#############
R Script
#############
library(data.table)
library(dplyr)

# Download pysradb metadata
system('pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv')

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
```
```R
#############
R Script
#############
library(data.table)
library(dplyr)

# Download pysradb metadata
system('pysradb metadata "${PWD##*/}" --detailed --saveto "${PWD##*/}"_PysradbTable.tsv')

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
#############
R Script
#############
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
# 4. Prefetch SRA data
Download SRA files for each project; do this in parallel (split into 15 parallel jobs).
```bash
# pwd = fastq

# Load modules
module load SRA-Toolkit/3.0.0-centos_linux64
module load parallel/20210722-GCCcore-11.2.0

# Sort out the formatting on all sra_table files
for f in PR* ; do Rscript format_sra_tables.R "$f"; done

# Make an accession list of runs for each project
# Do this by extracting the first column of each SraRunTable.txt file (minus the table header)
for f in PR*
do awk -v OFS='\t' 'NR>1{print $1}' "$f"/"$f"_SraRunTable.txt > "$f"/"$f"_SraAccList.txt
done

# Check that accession files contain the run numbers and not other info
cat prja_list.txt | parallel "echo {}; head -3 {}/{}_SraAccList.txt"

# Download SRA files
# Use nohup to keep jobs running in background even when logged off
# nohup cat prja_list.txt | parallel "prefetch --option-file {}/{}_SraAccList.txt --max-size 420000000000 -O {}/{}" &> output.out &
nohup cat prja_list.txt | parallel "prefetch --option-file {}/{}_SraAccList.txt --max-size 420000000000 -O {}/sra_files" &> output.out &
```
where Rscript format_sra_tables.R is 
```R
# Extract project name from argument passed in on command line
prjna <- commandArgs(trailingOnly = T)

# Read in data
sra_table = data.table::fread(paste0(prjna, "/", prjna, "_SraRunTable.txt"),data.table = F)

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna, "/", prjna,"_SraRunTable.txt"), sep='\t')
```

After the download has finished, do a basic check to test that the number of sra files matches with the number of SRA accessions for each project. We can then rerun the download for any projects/reads that weren't successful.
```bash
# Check log file
cat output.out

# Print a summary of the number of sra/sralite files that have been downloaded for each project
# Not sure how robust this is but it works for now
echo "-----------"; \
for f in PR*; do
  # Count how many sra files exit
  n_sra_files=$(ls "$f"/sra_files/*/*.sra | wc -l)
  if [[ -e "$f"/sra_files/*/*.sralite ]]
  then
    n_sralite_files=$(ls "$f"/sra_files/*/*.sralite | wc -l)
  else
    n_sralite_files=0
  fi
  # Total number of sra/sralite files
  n_sra_total=$(($n_sra_files + $n_sralite_files))
  # Count how many read accession numbers we have
  n_sra_acc=$(cat "$f"/"$f"_SraAccList.txt | wc -l)
  # Print a summary
  echo "$f: $n_sra_total/$n_sra_acc SRA files downloaded"
  echo "-----------"
done

# Print all run accessions
for f in PR*; do
  while read p; do
    echo "$p"
  done <"$f"/"$f"_SraAccList.txt
done

# Take a look at which files have downloaded sucessfully for a chosen project
tree PRJNA421274/sra_files

nohup prefetch --option-file PRJNA766716/PRJNA766716_SraAccList.txt --max-size 420000000000 -O PRJNA766716/PRJNA766716 &> output3.out &

ps -wx

# rerun and then search for failed downloads
nohup prefetch --option-file PRJNA421274_SraAccList.txt --max-size 420000000000 -O sra_files &> output2.out &

grep "failed" output2.out
# 2023-03-14T01:03:34 prefetch.3.0.0: 84) failed to download 'SRR6350505': RC(rcExe,rcFile,rcCopying,rcLock,rcExists)

# For any run that still do not download sucessfully, prefetch them individually, e.g:
cd PRJNA421274
nohup prefetch SRR6350505 --max-size 420000000000 -O sra_files &> output3.out &
cd ..

# Run a check on all sra files in the background and check for errors
for f in P*; do vdb-validate "$f"/sra_files/*/*.sra &>> vdb_all.out; done & 
grep "err" vdb_all.out
```


# 5. Make fastq files using fasterq-dump
Log into an interactive load on slurm for more cores. Fasterq-dump does not allow you to input a list of SRA numbers.
```bash
# Load modules
module load SRA-Toolkit/3.0.0-centos_linux64
module load parallel/20210722-GCCcore-11.2.0

nohup cat prja_list2.txt | parallel "mkdir {}/raw_reads; fasterq-dump {}/{} -O {}/raw_reads" &> output_fq.out &

# Or for a specific project
nohup cat PRJNA421274_SraAccList.txt | parallel fasterq-dump sra_files/{} -O raw_reads &> output_fq.out &

# Run fasterq-dump array script to create fastq files from SRA files
# This sends off 15 array scripts - one for each project
# Each of these scripts runs fasterq-dump in parallel for each run in the project
sbatch fasterq-dump.sh

# Run a quick check to make sure that we have all of the desired fastq files
# This includes paired and/or unmatched reads
for f in PR*; do
  while read p; do
  path=$f/raw_reads/
    if [[ ! -f "$path""$p".fastq && (! -f "$path""$p"_1.fastq || ! -f "$path""$p"_1.fastq) ]]
    then
      echo "Not all SRA files converted to fastq files for project $f. Please check run $p"
    fi
  done <"$f"/"$f"_SraAccList.txt
done
```
# 6. Compress fastq files
Fasterq-dump has no compression argument - we will have to do this explicitly. This is really slow, so send off some array scripts.
```bash

# Compress all fastq files
for f in PR*; do
  while read p; do
    gzip "$f"/raw_reads/"$p"*.fastq
  done <"$f"/"$f"_SraAccList.txt
done

# Use script - this is faster
# Still testing it
sbatch compress_fastq_files.sh
```
