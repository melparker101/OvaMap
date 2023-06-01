# 1. Datasets were manually filtered so that we only have 10X
There are 7 datasets:

### 10X Datasets
| Project acc.  | Dataset Name | Number of Samples | Number of runs   | Multiple runs per sample? | R1 and R2 availible? |
| :-----------: |:------------:|:-----------------:|:----------------:|:-------------------------:|:--------------------:|
| PRJNA766716   | Xu10X        | 5                 | 20               | Y                         | Y                    |
| PRJNA836755   | Jin10X       | 8                 | 8                | N                         | Y                    |
| PRJNA792835   | Guahmich10X  | 9                 | 10               | Y                         | Y                    |
| PRJNA754050   | Sood10X      | 1                 | 1                | N                         | Y                    |
| PRJNA484542   | Fan10X       | 31                | 31               | N                         | N                    |
| PRJNA879764   | Fonseca10X   | 4                 | 11               | Y                         | Y                    |
| PRJNA849410   | Choi10X      | 4                 | 8                | Y                         | Y                    |

# 1. Extract
Download fastq file

# 2. Rename fastq files
Rename so that they match the fastq format for cell ranger.
As projects PRJNA766716, PRJNA792835, PRJNA879764 and PRJNA849410 contain multiple runs per sample, the lane number should exist in the header. Check this:
```

projects=("PRJNA766716" "PRJNA792835" "PRJNA879764" "PRJNA849410")

for P in "${projects[@]}"
do
    echo "Processing project: $P"
    cd "$P"/raw_reads
    ls 
    
    while read p; do
      if [[ -f "$p"_1.fastq.gz ]]; then
        zcat "$p"_1.fastq.gz | head -1
      elif [[ -f "$p".fastq.gz ]]; then
        zcat "$p".fastq.gz | head -1
      fi 
    done <../"$P"_SraAccList.txt
    
    cd ../..
done

##########
for P in "${projects[@]}"
do
    echo "Processing project: $P"
    cd "$P"/raw_reads
    ls 
    
    
    cd ../..
done


for P in PRJNA766716, PRJNA792835, PRJNA879764 and PRJNA849410
cd "$P"/raw_reads

# Make a little loop to say which type of reads they are
while read p; do
  # If there aren't 3 fastq files for a run
  if [[ ! -f "$p"_3.fastq.gz ]]; then
  lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)
  length1=$(zcat "$p"_1.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
  length2=$(zcat "$p"_2.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
  echo "$p: There are two reads for this run. Read 1 has length $length1 and read 2 has length $length2"
  else
    echo "$p: There are three reads for this run."
  fi
done <../"$P"_SraAccList.txt


zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1****

```
