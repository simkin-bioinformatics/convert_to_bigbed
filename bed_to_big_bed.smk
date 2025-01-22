input_bed_file = '/home/charlie/projects/splicewiz/genomes/bigGenePred_drosophila_bdg.txt'
chrom_sizes = '/home/charlie/projects/splicewiz/genomes/drosophila_bdg.chrom.sizes'
output_folder = '/home/charlie/projects/splicewiz/genomes/drosophila_bdg_bigbed'

import os
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

file_name = input_bed_file.split('/')[-1].split('.')[0]
sorted_bed = f'{output_folder}/{file_name}_sorted.bed'
big_bed = f'{output_folder}/{file_name}.bb'


rule all:
	input:
		big_bed = big_bed

rule sort_bed_file:
	#sorts the bed file alphabetically
	input:
		unsorted_bed = input_bed_file
	output:
		sorted_bed = sorted_bed
	shell:
		'LC_COLLATE=C sort -k1,1 -k2,2n {input.unsorted_bed} > {output.sorted_bed}'
		#'sort -k1,1 -k2,2n {input.unsorted_bed} > {output.sorted_bed}'

rule make_big_bed:
	#converts the bed file into a bigbed file
	input:
		sorted_bed = sorted_bed,
		chrom_sizes = chrom_sizes
	output:
		big_bed = big_bed
	shell:
		'bedToBigBed -type=bed12+8 -tab {input.sorted_bed} {input.chrom_sizes} {output.big_bed}'