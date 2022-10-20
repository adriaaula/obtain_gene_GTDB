nextflow.enable.dsl=2

process translate_seq {
    maxForks 50
    tag "TRANS"

    input:
    path genome

    output: 
    path "${genome.baseName}.faa" 

    script:
    """
    seqkit translate -T 11 $genome > "${genome.baseName}.faa"
    """

}

process hmmsearch {
    maxForks 25

    input:
    path transch
    path hmm
    val threshold

    output: 
    path "${transch.baseName}_hmm.txt"

    script:
    """
    hmmsearch  -T ${threshold} \
               --tblout ${transch.baseName}_hmm.txt  \
               $hmm \
               $transch
    
    # adding to all lines the genome name 
    sed -ie 's/^/${transch.baseName}\t/' ${transch.baseName}_hmm.txt
    """

}

process obtain_sequences_and_tax{
    publishDir "$params.outdir", mode: 'copy', overwrite: true

    input:
    path allres

    output:
    path fasta
    path parsed_allres
    path tax

    shell:
    '''
    # obtain sequences

    # skip all lines presenting headers only 
    grep -v '_protein\t#' !{allres} > parsed_allres

    # iterate and search
    awk '{print $1, $2}' parsed_allres | while read gene;
    do
        pat=$(echo $gene | awk '{print $2}');
        file=$(echo $gene | awk '{print $1}' | sed 's/_protein//g');
        seqkit grep -r -n -p "$pat " \
        ~/scratch/protein_fna_reps/bacteria/$file* | \
        sed "s/>/>${file}_/g" >> fasta;
    
    done;   

    # obtain taxonomy
    cut -f1,1 parsed_allres | sed 's/_protein*//g' > to_parse.txt
    wget https://data.gtdb.ecogenomic.org/releases/latest/bac120_taxonomy.tsv.gz

    gzip -d bac120_taxonomy.tsv.gz
    grep -f to_parse.txt bac120_taxonomy.tsv > tax

    rm bac120_taxonomy.tsv
    '''

}

workflow {

   genomes = Channel.fromPath(params.genomes)
   transch = translate_seq(genomes)

   hmm = hmmsearch(transch, params.hmm, params.threshold)

   allres = hmm.collectFile(name: 'hmm_res.txt')

   seq = obtain_sequences_and_tax(allres)

}

