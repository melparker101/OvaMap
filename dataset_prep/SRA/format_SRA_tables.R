######################################
# This script formats the SRA tables
# Run it with the project name as an argument
######################################

# Extract project name
prjna <- commandArgs(trailingOnly = T)

# Read in data
sra_table = data.table::fread(paste0(prjna, "/", prjna, "_SraRunTable.txt"),data.table = F)

# Write to file, replacing the original
data.table::fwrite(sra_table, paste0(prjna, "/", prjna,"_SraRunTable.txt"), sep='\t')
