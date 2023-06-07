# In progress... Make one loop with different options:
# - one fastq file per run
# - two fastq files per run: lengths 28 and ~150
# - two fastq files per run: lengths 150 for both
# - three fastq files per run: lengths 8, 28 and ~150

# Potentially rerun fasterq on single read files

# To test this, copy raw reads and then run it all.
# projects=("PRJNA766716" "PRJNA792835" "PRJNA879764" "PRJNA849410")
# for P in "${projects[@]}"
# do
#     echo "Processing project: $P"
#     sh rename_fastq.sh $P
# done

# Start in the fastq directory... This contains all of the project directories
# 
# fastq/
# |-- PRJNA1
# |   |--raw_reads
# ...

P=$1  # Insert project accession as first argument
# p will be the read accession number

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

##########################
# For all types of fastqs
##########################

cd "$P"/raw_reads

##########################
# Chat GPT

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

#############################
##########################
# For reads split in 2 (lengths 28 and ~150)
##########################

while read p; do
    lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)
    length=$(zcat "$p"_1.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
    # If a third fastq file doesn't exist...
    if [[ ! -f "$p"_3.fastq.gz ]]; then
      # If the length of read 1 is 28, then...
      if [[ $length == 28 ]]; then
        echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
        mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
        mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz
      else 
        echo "Name of fastq file was not changed as reads from "$p"_1.fastq did not have length=28."
      fi
    fi
done <../"$P"_SraAccList.txt

while read p; do
    lane=$(zcat "$p"_1.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
    length=$(zcat "$p"_1.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
    echo $p
    echo $length
    echo $lane
done <../"$P"_SraAccList.txt

##########################
# For reads split in 3 (lengths 8,28,~150)
##########################

while read p; do
  if [[ -f "$p"_3.fastq.gz ]]; then
  lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)
  length1=$(zcat "$p"_1.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
  length2=$(zcat "$p"_2.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
  echo $length1
  echo $length2
    if [[ $length1 == 8 && $length2 == 28 ]]; then
      echo "$p"
        mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
        mv "$p"_3.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz
    else 
      echo "$p"
      echo "Name of fastq file was not changed as reads from "$p"_1.fastq did not have length 8 and/or "$p"_2.fastq did not have length=28."
    fi
  fi
done <../"$P"_SraAccList.txt

##########################
# For reads split in 2 (150,150)
##########################

while read p; do
  # If there aren't 3 fastq files for a run
  if [[ ! -f "$p"_3.fastq.gz ]]; then
  lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)
  length1=$(zcat "$p"_1.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
  length2=$(zcat "$p"_2.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
  echo $length1
  echo $length2
    # If there are two reads with length 150 each
    if [[ $length1 == 150 && $length2 == 150 ]]; then
      echo "$p"
        mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
        mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz
    else 
      echo "$p"
      echo "Name of fastq file was not changed as reads from "$p"_1.fastq did not have length 8 and/or "$p"_2.fastq did not have length=28."
    fi
  fi
done <../"$P"_SraAccList.txt



