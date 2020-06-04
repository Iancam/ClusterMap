# ClusterMap

ClusterMap is an R package designed to analyze and compare two or more single cell expression datasets. 

Please cite:
Gao X, Hu D, Gogol M, Li H. ClusterMap: Compare multiple Single Cell RNA-Seq datasets across different experimental conditions. Bioinformatics. 2019. doi: 10.1093/bioinformatics/btz024.

## Installation
R(>=4), Seurat(>= 2.2.1),pheatmap(>= 1.0.10),ape(>= 5.1),circlize(>= 0.4.3)
```r
install_github('devtools')  
library('devtools')  
install_github("Iancam/ClusterMap")
library('ClusterMap')  
```

If you encounter

<pre style="color: 'red';">
Error in cluster_map(marker_file_list, edge_cutoff = 0.1, output = "am",  : 
 Sample label in comb_obj doesn't match names(new_group_list) or names(single_obj_list).
</pre>

Include `comb_delim = <delim>` in your arguments to `cluster_map`.
To find the right comb_delim, run: 
```r
head(colnames(Seurat::GetAssayData(object = <comb_obj>)))
[1] "ctr-AAACCTGCATTGGGCC" "ctr-AAACCTGTCAGTCCCT" "ctr-AAACCTGTCGCCTGAG" "ctr-AAACGGGAGTGGTAGC"
[5] "ctr-AAACGGGAGTTCCACA" "ctr-AAAGATGGTGCAACTT"
```
In this example, SNPs are separated from their group `ctr` with '-', so you would pass `comb_delim = '-'` into ClusterMap.

```r
cluster_map(marker_file_list,
                   edge_cutoff = 0.1,
                   output = 'am',
                   single_obj_list = single_obj_list,
                   comb_obj = objList$AMac,
                   comb_delim = "-")
```


## Tutorial

https://xgaoo.github.io/ClusterMap/ClusterMap.html
