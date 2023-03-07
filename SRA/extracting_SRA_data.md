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
cd fastq

cat > prja_list.txt
# Insert list of accession numbers for projects availible on SRA
```

Make a directory for each project accession number.

```console
while read p; do mkdir "$p"; done < prja_list.txt
```

### 2. Download metadata file for each project accession

```console
# Get metadata for each entry
for p in P*
do esearch -db sra -query "$p" | efetch -format runinfo > "$p"/"$p"_SraRunTable.txt
done 
```
