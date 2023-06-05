This code copies the SRA tables over to the ovaMap directory, renaming them to the format required for the raw_hypoMap_datasets.R script.

PRJNA766716	Xu10X
PRJNA836755	Jin10X
PRJNA792835	Guahmich10X
PRJNA754050	Sood10X
PRJNA879764	Fonseca10X
PRJNA849410	Choi10X

We want the format: SraRunTable_<dataset>.txt

```bash
# $PWD=//well/lindgren/users/mzf347/ovaMap/fastq

projects=("PRJNA766716" "PRJNA836755" "PRJNA792835" "PRJNA754050" "PRJNA879764" "PRJNA849410")
datasets=("Xu10X" "Jin10X" "Guahmich10X" "Sood10X" "Fonseca10X" "Choi10X")
SraTableDir="//well/lindgren/users/mzf347/ovaMap/data/ovaMap_rawdata/SRAtables"

for ((i=0; i<${#projects[@]}; i++))
do
  P="${projects[i]}"
  D="${datasets[i]}"
  echo "Processing project: $P, dataset: $D"
  echo "$P"/"$P"_SraRunTable.txt
  echo "$SraTableDir"/SraRunTable_"$D".txt
  echo ""
  # cp "$P"/"$P"_SraRunTable.txt "$SraTableDir"/SraRunTable_"$D".txt
done
```
