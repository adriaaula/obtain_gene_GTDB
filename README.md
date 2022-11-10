# obtain_gene_GTDB
A small nextflow workflow to retrieve all the hits for an specific gene of interest with HMM from GTDB

## Main flow

Initially the user should obtain the CDS for the representative GTDB species. 
Find them [here](https://data.gtdb.ecogenomic.org/releases/latest/genomic_files_reps/). After downloading, it should be decompressed with `tar -xvzf <file>` (it will also take a while). 

Addtionally to that download the user should download the HMM and find an appropiate threshold to which filter out the false positive results. 
In our case we use the KOFAM HMM, and the filter threshold is based in the one specified [here](https://www.genome.jp/ftp/db/kofam/).

Afterwards, we can use the workflow specifying all the inputs described in the `nextflow.config` inside the file itself or as follows:

```
nextflow run retrieve_genes_specific_ko.nf --genomes <your_genomes_cds_path> \
    --hmm <hmm_path> \
    --threshold <the value> \
    --outdir <output_dir>
```

Indicating the `nextflow run re... -resume` variable you can restart the pipeline with the cached values.

Enjoy!

## Dependencies

- nextflow (DSL = 2)
- hmmer
- seqkit (https://bioinf.shenwei.me/seqkit/)

