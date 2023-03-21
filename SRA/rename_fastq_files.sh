# Start in the fastq directory... This contains all of the project directories
# 
# fastq/
# |-- PRJNA1
# |   |--raw_reads
# ...

P=$1  # Insert project accession as first argument
# p will be the read accession number

cd "$P"/raw_reads

while read p; do
    lane=$(zcat "$p"_1.fastq.gz | awk -F: '{print $4}' | head -1)
    length=$(zcat "$p"_1.fastq.gz | awk -F'[=\" "]' '{print $4}' | head -1)
    if [[ ! -f "$p"_3.fastq.gz ]]; then
      if [[ $length == 28 ]]; then
        echo "$p"_S1_L00"$lane"_R1_001.fastq.gz
        mv "$p"_1.fastq.gz "$p"_S1_L00"$lane"_R1_001.fastq.gz
        mv "$p"_2.fastq.gz "$p"_S1_L00"$lane"_R2_001.fastq.gz
      else 
        echo "Name of fastq file was not changed as reads from "$p"_1.fastq did not have length=28."
      fi
    fi
done <../"$P"_SraAccList.txt

# Rename the reads that split into three
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
