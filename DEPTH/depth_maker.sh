#!/bin/bash


## Usage: sh depth_maker.sh reference_genome.fasta /path/to/pair_end_read_1.fastq  /path/to/pair_end_read_2.fastq chromosome_list.txt output_prefix  ##



# Accepting and checking arguments
fasta=$1
read_1=$2
read_2=$3
chromosome_list=$4
output=$5

if [[ $# -lt 5 ]] ; then {
    echo "Too few arguments given, kindly check again and re-run"
    exit 1
	}
fi;
#------------------------------------------------------


# Removing files with identical output_prefix from previous analysis
rm -rf $output*
#------------------------------------------------------

echo "Provided reference genome fasta file is" $fasta >> $output"_logfile.txt"
echo "Read_1 and read_2 are" $read_1 $read_2 >> $output"_logfile.txt"
echo "File containing list of chromosomes from reference genome fasta file is" $chromosome_list >> $output"_logfile.txt"
echo "Output file name prefix is" $output >> $output"_logfile.txt"
echo "Indexing given genome" >> $output"_logfile.txt"


# Mapping pair_end_reads.fastq to reference_genome.fasta using BWA-MEM
bwa index -a is $fasta  -p  $output
echo "Indexing done and read mapping started" >> $output"_logfile.txt"
bwa mem -t 4 $output $read_1 $read_2 > $output"_all.sam"
echo "Read mapping is done and sam file generated as" $output"_all.sam" >> $output"_logfile.txt"
#-------------------------------------------------------


# Generating depth file using SAMtools
samtools view -h $output"_all.sam" | awk '{if($3!="*") print $0}' > $output"_mapped.sam"
samtools  view -S -b -h $output"_mapped.sam" -o $output"_mapped.bam"
samtools  sort $output"_mapped.bam" -o $output"_mapped_sorted.bam"
samtools  index $output"_mapped_sorted.bam"
echo "Sam file filtered from unmapped reads are present in" $output"_mapped.sam" >> $output"_logfile.txt"
#-------------------------------------------------------


# Checking  & generating depth file for uniquely mapped reads 
samtools view $output"_mapped_sorted.bam" | cut -f 1 | sort | uniq -c | awk '{if ($1>2) print $2}'  > $output"_multimapped_read.id"
if [[ -s $output"_multimapped_read.id" ]] ; then {
	
	echo "Reads mapping to multiple positions across entire genome sequence are detected, generating sam file for uniquely mapped reads" >> $output"_logfile.txt"
	
	sh split_bam_chrom.sh $1 $output $chromosome_list 
	wait
	
	mkdir $output"_tmp"
	split -l 500 -a 100 $output"_multimapped_read.id" $output"_tmp"/segment
	for s in $output"_bam_chrom_files"/*_mapped_sorted.bam
	do 
	
		sh unique_map.sh $output $s &
		
	
	done 
	wait 
	cat $output"_bam_chrom_files"/*_unique_sorted.depth > $output"_bam_chrom_files"/$output"_GCDP.depth"
	#cat $output"_bam_chrom_files"/*_multimapped_sorted.depth > $output"_bam_chrom_files"/$4"_multimapped.depth"
	
	}
else { 
	echo "No reads mapping to multiple positions across genome sequence were detected" >> $output"_logfile.txt"
	
	}
	fi ; 	
#-------------------------------------------------------	
	
samtools depth $output"_mapped_sorted.bam" > $output"_mapped_sorted.depth"
echo "Total depth file generated at:" $output"_mapped_sorted.depth" >> $output"_logfile.txt"
wait
rm -rf $output"_tmp"
rm -rf $output"_bam_chrom_files"/*bam $output"_bam_chrom_files"/*bai $output"_bam_chrom_files"/*sam
echo "entire program completed" >> $output"_logfile.txt"







