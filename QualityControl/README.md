# Quality Control

In this folder, the scripts present are:

### `subsample_salmon.sh`

This script subsamples your fastq's and runs them through salmon. It is helpful mainly to ascertain the strandness of your data.
Usage:
```
subsample_salmon.sh --i <input_dir> --o <output_dir> --p <prop_of_reads> --n <number_of_reads> --g <genome_dir>\n
```
**folders**

`--i:` input directory (where the fastq files are)

`--o:` output directory (where the produced files will be stored) 
        in this folder, a subsampled & salmon_quant subfolders will be created
        
`--g:` folder where the reference genome is 
      The genome needs to be previously indexed using salmon index


**parameters**

`--n:` number of reads used for subsampling

`--p:` proportion of the reads used for subsampling

`--s:` seed (seqkit's default, 11)
