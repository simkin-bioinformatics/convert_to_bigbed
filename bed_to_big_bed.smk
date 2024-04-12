file = 'drorep_copia_annotations'
input_bed = f'/home/charlie/Dropbox/projects/search_for_copia/custom_copia_annotations/{file}.bed'
sorted_bed = f'/home/charlie/Dropbox/projects/search_for_copia/custom_copia_annotations/{file}_sorted.bed'
chrom_sizes = '/home/charlie/Dropbox/projects/search_for_copia/custom_copia_annotations/copia.chrom.sizes'
big_bed = f'/home/charlie/Dropbox/projects/search_for_copia/custom_copia_annotations/{file}.bb'


rule all:
	input:
		big_bed = big_bed

rule sort_bed_file:
	#sorts the bed file alphabetically
	input:
		unsorted_bed = input_bed
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
		'bedToBigBed -type=bed12+8 {input.sorted_bed} {input.chrom_sizes} {output.big_bed}'