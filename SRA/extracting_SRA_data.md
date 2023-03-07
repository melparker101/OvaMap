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
