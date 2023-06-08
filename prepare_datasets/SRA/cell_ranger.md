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
Download fastq files.  
PRJNA484542 only contains forward reads. We cannot use cell ranger on it and will have to use bam to fastq later. This leaves us with six 10X datasets to use.

# 2. Rename fastq files
Rename so that they match the fastq format for cell ranger.
As projects PRJNA766716, PRJNA792835, PRJNA879764 and PRJNA849410 contain multiple runs per sample, the lane number should exist in the header. Check this:
```

projects=("PRJNA766716" "PRJNA836755" "PRJNA792835" "PRJNA754050" "PRJNA879764" "PRJNA849410")
for P in "${projects[@]}"
do
    echo "Processing project: $P"
    cd "$P"/raw_reads
    ls
    cd ../..
done

##############################

# Make a little loop to state which type of reads they are
cd "$P"/raw_reads

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


zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1
##################################

```
PRJNA754050 and PRJNA836755 only have 1 run per sample, so the lane number is not included in the header. 
```
# These samples only have one run per sample so set lane number to 1
projects=("PRJNA836755" "PRJNA754050")

for P in "${projects[@]}"
    do
        cd "$P"/raw_reads

        while read -r p; do
          length=$(zcat "$p".fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)  # Length of single fastq reads
          length1=$(zcat "$p"_1.fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)  # Length of read 1 multiple fastq reads
          length2=$(zcat "$p"_2.fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)
          length3=$(zcat "$p"_3.fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)
          length4=$(zcat "$p"_4.fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)
          lane=1  # Set lane as constant

          # 1. One fastq file per run
          if [[ -f "$p".fastq.gz ]]; then
            echo "Rerun fasterq-dump for $p"

          # 2. Two fastq files per run (lengths <=30 and ~150) - make sure the read with 28 is labelled as R1
          elif [[ ! -f "$p"_3.fastq.gz && $length1 -le 30 ]]; then
            echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz  # Rename fastq files
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz

          # 3. Two fastq files with length ~150 each (or at least >50) - it doesn't matter which is R1 and R2?
          elif [[ ! -f "$p"_3.fastq.gz && $length1 -ge 50 && $length2 -ge 50 ]]; then
            echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz

          # 4. Three fastq files (lengths <=10,<=30,~150)
          elif [[ ! -f "$p"_4.fastq.gz && -f "$p"_3.fastq.gz && $length1 -le 10 && $length2 -le 30 ]]; then
            echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_I1_001.fastq.gz
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_3.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz

          # 5. Four fastq files (I1, I2, R1 (L~28) and R2 (L>50))
          elif [[ -f "$p"_4.fastq.gz && $length3 -le 30 && $length4 -ge 50 ]]; then
            echo "$p"_S1_L00"$lane"_I1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_I1_001.fastq.gz
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_I2_001.fastq.gz
            mv "$p"_3.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_4.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz

          # Otherwise, print a message
          else
            echo "$p was not renamed."
          fi
        done < ../"$P"_SraAccList.txt
        
        cd ../..
done

#########################################################
# These samples have multiple runs per sample so extract the lane number

projects=("PRJNA766716" "PRJNA792835" "PRJNA879764" "PRJNA849410")
for P in "${projects[@]}"
    do
        cd "$P"/raw_reads

        while read -r p; do
          length=$(zcat "$p".fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)  # Length of single fastq reads
          length1=$(zcat "$p"_1.fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)  # Length of read 1 multiple fastq reads
          length2=$(zcat "$p"_2.fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)
          length3=$(zcat "$p"_3.fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)
          length4=$(zcat "$p"_4.fastq.gz | awk -F'[=" "]' '{print $4}' | head -1)

          # 1. One fastq file per run
          if [[ -f "$p".fastq.gz ]]; then
            echo "Rerun fasterq-dump for $p"

          # 2. Two fastq files per run (lengths <=30 and ~150) - make sure the read with 28 is labelled as R1
          elif [[ ! -f "$p"_3.fastq.gz && $length1 -le 30 ]]; then
            lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)  # Extract lane number from header
            echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz  # Rename fastq files
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz

          # 3. Two fastq files with length ~150 each (or at least >50) - it doesn't matter which is R1 and R2?
          elif [[ ! -f "$p"_3.fastq.gz && $length1 -ge 50 && $length2 -ge 50 ]]; then
            lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)
            echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz

          # 4. Three fastq files (lengths <=10,<=30,~150)
          elif [[ ! -f "$p"_4.fastq.gz && -f "$p"_3.fastq.gz && $length1 -le 10 && $length2 -le 30 ]]; then
            lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)
            echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_I1_001.fastq.gz
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_3.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz

          # 5. Four fastq files (I1, I2, R1 (L~28) and R2 (L>50))
          elif [[ -f "$p"_4.fastq.gz && $length3 -le 30 && $length4 -ge 50 ]]; then
            lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)
            echo "$p"_S1_L00"$lane"_I1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_I1_001.fastq.gz
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_I2_001.fastq.gz
            mv "$p"_3.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_4.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz

          # Otherwise, print a message
          else
            echo "$p was not renamed."
          fi
        done < ../"$P"_SraAccList.txt
        
        cd ../..
done

```
