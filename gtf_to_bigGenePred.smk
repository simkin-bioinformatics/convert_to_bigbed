# input a fasta file and a gtf file
# output a bigbed file and a 2bit file suitable for ucsc browser annotation

fasta_file = '/home/charlie/projects/genomes_and_te/Drosophila_melanogaster.BDGP6.32.fa'
gtf_file = '/home/charlie/projects/genomes_and_te/Drosophila_melanogaster.BDGP6.32_copia.gtf'
output_folder = '/home/charlie/projects/browserDocker/site_data/copia_bdgp6_gtf'
email = 'charlie.simkin@gmail.com'
default_position = open(fasta_file, 'r').readline().strip().split()[0].strip(">")

genome_name = fasta_file.split('/')[-1].replace('.fa','')
annotation_name = gtf_file.split('/')[-1].replace('.gtf','')
chrom_sizes = output_folder + '/' + fasta_file.split('/')[-1].replace('.fa','.chrom.sizes')
gene_pred = output_folder + '/' + gtf_file.split('/')[-1].replace('.gtf','.genePred')
big_gene_pred = gene_pred.replace('.genePred','.bigGenePred')
sorted_big_gene_pred = big_gene_pred.replace('.bigGenePred','_sorted.bigGenePred')
big_bed = big_gene_pred.replace('bigGenePred','bb')
two_bit = output_folder + '/' + fasta_file.split('/')[-1].replace('.fa','.2bit')
assembly_hub = output_folder + '/' + fasta_file.split('/')[-1].replace('.fa','_assembly_hub.txt')
annotation_hub = output_folder + '/' + gtf_file.split('/')[-1].replace('.gtf','_annotation_hub.txt')


rule all:
    input: 
        big_bed = big_bed,
        two_bit = two_bit,
        assembly_hub_file = assembly_hub,
        annotation_hub_file = {annotation_hub}

rule get_chrom_sizes:
    input:
        fasta_file = fasta_file
    output:
        chrom_sizes = chrom_sizes
    shell:
        'faSize -detailed {input.fasta_file} > {output.chrom_sizes}'

rule gtf_to_gene_pred:
    input:
        gtf_file = gtf_file
    output:
        gene_pred = gene_pred
    shell:
        'gtfToGenePred -genePredExt {input.gtf_file} {output.gene_pred}'

rule genePredToBigGenePred:
    input:
        gene_pred = gene_pred
    output:
        big_gene_pred = big_gene_pred
    shell:
        'genePredToBigGenePred {input.gene_pred} {output.big_gene_pred}'

rule sort_bigGenePred:
    #sorts the bed file alphabetically
    input:
        unsorted_big_gene_pred = big_gene_pred
    output:
        sorted_big_gene_pred = sorted_big_gene_pred
    shell:
        'LC_COLLATE=C sort -k1,1 -k2,2n {input.unsorted_big_gene_pred} > {output.sorted_big_gene_pred}'

rule get_as_file:
    output:
        as_file = 'bigGenePred.as'
    shell:
        'wget https://genome.ucsc.edu/goldenPath/help/examples/bigGenePred.as'

rule bigGenePred_to_bigBed:
    input:
        sorted_big_gene_pred = sorted_big_gene_pred,
        chrom_sizes = chrom_sizes,
        as_file = 'bigGenePred.as'
    output:
        big_bed = big_bed
    shell:
        'bedToBigBed -type=bed12+8 -tab -as=bigGenePred.as {input.sorted_big_gene_pred} {input.chrom_sizes} {output.big_bed}'

rule create_hubs:
    output:
        assembly_hub_file = {assembly_hub},
        annotation_hub_file = {annotation_hub}
    run:
        with open(output[0],'w') as assembly_out:
            assembly_out.write(
                f"hub {genome_name}\n"
                f"shortLabel {genome_name}\n"
                f"longLabel {genome_name}\n"
                f"useOneFile on\n"
                f"email {email}\n"
                f"\n"
                f"genome {genome_name}\n"
                f"description {genome_name}\n"
                f"twoBitPath {genome_name}.2bit\n"
                f"organism {genome_name}\n"
                f"defaultPos {default_position}\n"
                f"scientificName {genome_name}\n"
                f"transBlat localhost 17777\n"
                f"blat localhost 17779\n"
                f"isPcr localhost 17779"
            )
        with open(output[1],'w') as annotation_out:
            annotation_out.write(
                f"hub {annotation_name} annotations\n"
                f"shortLabel {annotation_name}\n"
                f"longLabel {annotation_name} annotations\n"
                f"useOneFile on\n"
                f"email {email}\n"
                f"\n"
                f"genome {genome_name}\n"
                f"\n"
                f"track {annotation_name}_annotations\n"
                f"shortLabel {annotation_name}\n"
                f"longLabel {annotation_name} annotations\n"
                f"visibility full\n"
                f"baseColorDefault genomicCodons\n"
                f"type bigGenePred\n"
                f"bigDataUrl {big_bed.split('/')[-1]}\n"
                f"color 40,40,40"
            )
rule make_2bit:
    input:
        fasta_file = fasta_file
    output:
        two_bit = two_bit
    shell:
        'faToTwoBit {input.fasta_file} {output.two_bit}'
