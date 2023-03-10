# Functions for group 1 scVI ovaMap

##############################
# Normalisation
##############################
# Code copied from scvi page - https://docs.scvi-tools.org/en/stable/tutorials/notebooks/api_overview.html
def normaliseData(adata):
  adata.layers["counts"] = adata.X.copy()  # preserve counts
  sc.pp.normalize_total(adata, target_sum=1e4)
  sc.pp.log1p(adata)
  adata.raw = adata  # freeze the state in `.raw`
    
##############################
# Reading in multiple data
##############################
def readMultipleData(acc_key):
  # E.g. acc_key = "GEO123456"  
  c = 1  # Set count
  # Create a dictionary with the name data_GEO123456 
  d = {}
  dict_name = "_".join(["data", acc_key])
  globals()[dict_name] = d
  # Define path
  list = ["data", acc_key, "index.txt"]
  index_path = "/".join(list)
  with warnings.catch_warnings():
    warnings.simplefilter('ignore')
    # Loop through files in dir and read data into dict
    with open(index_path, 'r') as f:
           for line in f:
              line = line.strip()  # Get rid of /n
              # print(line)
              # Read in data
              list = ["data", acc_key, line]
              file_path = "/".join(list)
              data = sc.read_10x_h5(file_path)
              data.var_names_make_unique()  # Make variables unique
              adata_name = "".join(["data", str(c)])
              # Add adata and its name to dictionary
              d[adata_name] = data
              c+=1
  # Turn dictionary keys/values into variables
  globals().update(d)

##############################
# Filtering mitochondria
##############################
def filterByMtFrac(adata, percent):
  adata.var['mt'] = adata.var_names.str.startswith('MT-')
  sc.pp.calculate_qc_metrics(adata, qc_vars = ['mt'], percent_top = None, log1p = False, inplace = True)
  # Remove cells with more than % MT
  adata = adata[adata.obs.pct_counts_mt < percent]
  return adata
