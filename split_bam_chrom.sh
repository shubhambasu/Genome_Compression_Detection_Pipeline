#!/bin/bash
## Usage: sh split_bam_chrom.sh  reference_genome.fasta	output_prefix 	chromosome_list.txt

echo "Splitting whole genome bam file based on chromosomes has started" >> $2"_logfile.txt"

# Splitting entire bam file based on chromosomes provided in chromosome_list.txt
mkdir $2"_bam_chrom_files"
cat $3 | while read line 
do 
	echo $line > $3"_tmp"
	chrom=$(cat $3"_tmp"  | awk '{print $1}' )
	samtools view -h -b $2"_mapped_sorted.bam" $chrom > $2"_bam_chrom_files"/$chrom"_mapped_sorted.bam" 
	echo "Indexed and sorted bam file for" $chrom "is generated" >> $2"_logfile.txt"
		
done 
rm $3"_tmp" 
echo "Splitting whole genome bam file based on chromosomes has ended" >> $2"_logfile.txt"
#------------------------------------------------------