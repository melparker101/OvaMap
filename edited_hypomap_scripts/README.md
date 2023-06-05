Scripts taken from the [hypoMap](https://github.com/lsteuernagel/hypoMap_datasets) github and edited to work with the ovary data we have collected.
1. Merge count data with corresponding SRA metadata:
```bash
Rscript raw_hypoMap_datasets.R | tee logs/raw_hypoMap_datasets.log
```
