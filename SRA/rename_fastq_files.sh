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
# For reads that are not split
##########################

while read p; do

    # If the reads are not split
    if [[ -f "$p".fastq.gz ]]; then
        # Create string for lane and read length
        lane=$(zcat "$p".fastq.gz | awk -F: '{print $4}' | head -1)
        length=$(zcat "$p".fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
          
          # If the length of read 1 is 28, then...
          if [[ $length == 28 ]]; then
            echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
            mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz
          else 
            echo "Name of fastq file for run "$p" was not changed."
          fi
      fi
done <../"$P"_SraAccList.txt


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



