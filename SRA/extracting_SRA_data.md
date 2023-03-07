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
```console
cd "$MYDIR"/ovaMap/fastq

cat > prja_list.txt
# Insert list of accession numbers for projects availible on SRA
```

Make a directory for each project accession number.
```console
while read p; do mkdir "$p"; done < prja_list.txt
```

### 2. Download metadata file for each project accession
Install EDirect software from NCBI.
```console
cd ~

# This downloads into homefile automatically
sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"

# Move it to software directory
mv edirect "$MYDIR"/software/
```

Add the following line to .bashrc.
```console
export PATH=${PATH}:"$MYDIR"/software/edirect
```

Get metadata for each entry.
```bash
cd "$MYDIR"/ovaMap/fastq

for p in P*
do esearch -db sra -query "$p" | efetch -format runinfo > "$p"/"$p"_SraRunTable.txt
done 
```

```sh
cd "$MYDIR"/ovaMap/fastq

for p in P*
do esearch -db sra -query "$p" | efetch -format runinfo > "$p"/"$p"_SraRunTable.txt
done 
```

```zsh
cd "$MYDIR"/ovaMap/fastq

for p in P*
do esearch -db sra -query "$p" | efetch -format runinfo > "$p"/"$p"_SraRunTable.txt
done 
```

Check that this has worked.
```console
tree .
```

