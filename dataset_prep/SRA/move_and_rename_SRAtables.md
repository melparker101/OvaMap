This code copies the SRA tables over to the ovaMap directory, renaming them to the format required for the raw_hypoMap_datasets.R script.

PRJNA766716	Xu10X
PRJNA836755	Jin10X
PRJNA792835	Guahmich10X
PRJNA754050	Sood10X
PRJNA879764	Fonseca10X
PRJNA849410	Choi10X

We want the format: SraRunTable_<dataset>.txt.

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

The following code copies all of the cellranger counts over to the ovaMap directory:                              
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
  
This is what the directory structure should look like afterwards:
```
$ pwd
//well/lindgren/users/mzf347/ovaMap/data/ovaMap_rawdata

$ tree -L 2 .
.
|-- Choi10X
|   |-- run_count_SRR19660773
|   |-- run_count_SRR19660774
|   |-- run_count_SRR19660775
|   |-- run_count_SRR19660776
|   |-- run_count_SRR19660777
|   |-- run_count_SRR19660778
|   |-- run_count_SRR19660779
|   `-- run_count_SRR19660780
|-- Fonseca10X
|   |-- run_count_SRR21536711
|   |-- run_count_SRR21536712
|   |-- run_count_SRR21536716
|   |-- run_count_SRR21536717
|   |-- run_count_SRR21536727
|   |-- run_count_SRR21536728
|   |-- run_count_SRR21536765
|   |-- run_count_SRR21536766
|   |-- run_count_SRR21536767
|   |-- run_count_SRR21536768
|   `-- run_count_SRR21536769
|-- Guahmich10X
|   |-- run_count_SRR17351745
|   |-- run_count_SRR17351746
|   |-- run_count_SRR17351750
|   |-- run_count_SRR17351751
|   |-- run_count_SRR17351752
|   |-- run_count_SRR17351753
|   |-- run_count_SRR17351754
|   |-- run_count_SRR19614723
|   |-- run_count_SRR19614728
|   `-- run_count_SRR19614729
|-- Jin10X
|   |-- run_count_SRR19153925
|   |-- run_count_SRR19153926
|   |-- run_count_SRR19153927
|   |-- run_count_SRR19153928
|   |-- run_count_SRR19153929
|   |-- run_count_SRR19153930
|   |-- run_count_SRR19153931
|   `-- run_count_SRR19153932
|-- SRAtables
|   |-- SraRunTable_Choi10X.txt
|   |-- SraRunTable_Fonseca10X.txt
|   |-- SraRunTable_Guahmich10X.txt
|   |-- SraRunTable_Jin10X.txt
|   |-- SraRunTable_Sood10X.txt
|   `-- SraRunTable_Xu10X.txt
|-- Sood10X
|   `-- run_count_SRR15424680
`-- Xu10X
    |-- run_count_SRR16093329
    |-- run_count_SRR16093330
    |-- run_count_SRR16093331
    |-- run_count_SRR16093332
    |-- run_count_SRR16093333
    |-- run_count_SRR16093334
    |-- run_count_SRR16093335
    |-- run_count_SRR16093336
    |-- run_count_SRR16093337
    |-- run_count_SRR16093338
    |-- run_count_SRR16093339
    |-- run_count_SRR16093340
    |-- run_count_SRR16093341
    |-- run_count_SRR16093342
    |-- run_count_SRR16093343
    |-- run_count_SRR16093344
    |-- run_count_SRR16093345
    |-- run_count_SRR16093346
    |-- run_count_SRR16093347
    `-- run_count_SRR16093348

65 directories, 6 files
```
