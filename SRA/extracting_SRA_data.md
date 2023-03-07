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

```console
cd fastq

cat > prja_list.txt
# insert list of accession numbers for projects availible on SRA
```

```console
while read p; do mkdir "$p"; done < prja_list.txt
```

Add some text here...

```console
# Get metadata for each entry
for p in P*
do esearch -db sra -query "$p" | efetch -format runinfo > "$p"/"$p"_SraRunTable.txt
done 
```
