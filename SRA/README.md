1. Run cellranger count. Use the nested script cell_ranger.sh to run this on all projects and all of their runs. 
```bash
cellranger_count/run_count_SRR15424680/outs/

projects=("PRJNA766716" "PRJNA836755" "PRJNA792835" "PRJNA754050" "PRJNA879764" "PRJNA849410")
datasets=("Xu10X" "Jin10X" "Guahmich10X" "Sood10X" "Fonseca10X" "Choi10X")
  
# Loop through each project and copy the count matrix
for ((i=0; i<${#projects[@]}; i++))
do
    project=${projects[i]}
    datasets=${datasets[i]}
    
    # Check if the project directory exists
        # Get the list of runs from the SraAccList.txt file
        runs=$(cat $project/${project}_SraAccList.txt)
        
    #echo "Project: $project, dataset: $dataset"
    #echo "Runs:" 
    #echo $runs
  #echo ""
  
  for run in $runs
        do
            # source_dir="cellranger_count/run_count_$run/outs/filtered_feature_bc_matrix"
            echo $run
            OUTS="cellranger_count/run_count_$run/outs/"
            echo $OUTS
            ls $OUTS
            echo ""  
    done

done
```
Check the runs that failed, e.g.: 
```bash
cat //well/lindgren/users/mzf347/ovaMap/fastq/cellranger_count/run_count_SRR17351745/_log
```

