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
  cp "$P"/"$P"_SraRunTable.txt "$SraTableDir"/SraRunTable_"$D".txt
done
```

                              
```bash
projects=("PRJNA766716" "PRJNA836755" "PRJNA792835" "PRJNA754050" "PRJNA879764" "PRJNA849410")
datasets=("Xu10X" "Jin10X" "Guahmich10X" "Sood10X" "Fonseca10X" "Choi10X")
rawdataDir="//well/lindgren/users/mzf347/ovaMap/data/ovaMap_rawdata"
  
# Loop through each project and copy the count matrix
for ((i=0; i<${#projects[@]}; i++))
do
    project=${projects[i]}
    datasets=${datasets[i]}
    
    # Check if the project directory exists
    if [ -d "$project" ]; then
        # Get the list of runs from the SraAccList.txt file
        runs=$(cat $project/${project}_SraAccList.txt)
        
    echo "Processing project: $project, dataset: $dataset"
    echo "Runs: $runs"
  echo ""
  
          # Loop through each run and copy the count matrix
        for run in $runs
        do
            # source_dir="cellranger_count/run_count_$run/outs/filtered_feature_bc_matrix"
            source_dir="cellranger_count/run_count_$run"
            target_dir="$rawdataDir/$datasets/"
            
            # Create the target directory if it doesn't exist
            mkdir -p "$target_dir"
            
            # Copy the count matrix to the target directory
            cp -R "$source_dir" "$target_dir"
        done
    fi
done
```
