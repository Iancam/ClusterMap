# ClusterMap

ClusterMap is an R package designed to analyze and compare two or more single cell expression datasets. 

Please cite:
Gao X, Hu D, Gogol M, Li H. ClusterMap: Compare multiple Single Cell RNA-Seq datasets across different experimental conditions. Bioinformatics. 2019. doi: 10.1093/bioinformatics/btz024.

## Installation
R(>=3.4.3), Seurat(>= 2.2.1),pheatmap(>= 1.0.10),ape(>= 5.1),circlize(>= 0.4.3)
```r
install_github('devtools')  
library('devtools')  
install_github("Iancam/ClusterMap")
library('ClusterMap')  
```

If you encounter
`Error in cluster_map(marker_file_list, edge_cutoff = 0.1, output = "am",  : 
 Sample label in comb_obj doesn't match names(new_group_list) or names(single_obj_list).`
Include `comb_delim = <delim>` in your arguments to `cluster_map`
`comb_delim` should be the separator in the comb_obj. To find this, run: 
```r
head(colnames(Seurat::GetAssayData(object = <comb_obj>)))
[1] "ctr-AAACCTGCATTGGGCC" "ctr-AAACCTGTCAGTCCCT" "ctr-AAACCTGTCGCCTGAG" "ctr-AAACGGGAGTGGTAGC"
[5] "ctr-AAACGGGAGTTCCACA" "ctr-AAAGATGGTGCAACTT"
```
In this example, SNPs are separated from their group with an '-', so you would pass `comb_delim = '-'` into ClusterMap.



## Tutorial

https://xgaoo.github.io/ClusterMap/ClusterMap.html
