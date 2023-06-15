REF=$REF_GENOMES/homo_sapiens/10xgenomics

# mkdir -p "$REF"
wget https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2020-A.tar.gz -P "$REF"

# Download reference file (this takes a while)
tar -xvf "$REF"/refdata-gex-GRCh38-2020-A.tar.gz 
rm "$REF"/refdata-gex-GRCh38-2020-A.tar.gz
