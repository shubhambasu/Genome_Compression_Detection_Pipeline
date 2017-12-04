#!/bin/bash
## Usage: sh unique_map.sh output chrom_bam_files

echo "Generation of depth file with uniquely mapped reads for" $2 " has started" >> $1"_logfile.txt"

# Splitting entire genome sam file based on reads which are mapped in unique regions and generating depth file using SAMtools
cp $2 $2"_tmp"
for f in $1"_tmp"/segment*
do

	samtools view -h $2 | grep -w -f $f >> $2"_multimapped.sam"		
	samtools view -h $2"_tmp" | grep -v -w -f $f > $2"_tmp_unique.sam"
	mv $2"_tmp_unique.sam" $2"_tmp" 

done 
mv $2"_tmp" $2"_unique.sam" 
samtools  view -S -b -h $2"_unique.sam"  -o $2"_unique.bam" 
samtools  sort $2"_unique.bam"  -o $2"_unique_sorted.bam" 
samtools  index $2"_unique_sorted.bam" 
samtools  depth $2"_unique_sorted.bam"  > $2"_unique_sorted.depth" 
		
echo "Generation of depth file with uniquely mapped reads for" $2 " has ended and stored as" $2"_unique_sorted.depth" >> $1"_logfile.txt"
#------------------------------------------------------

#samtools view -H $2 > $2"_header"
#cat $2"_multimapped.sam" >> $2"_header"
#mv $2"_header" $2"_multimapped.sam"
#samtools  view -S -b -h $2"_multimapped.sam" -o $2"_multimapped.bam"
#samtools  sort $2"_multimapped.bam" -o $2"_multimapped_sorted.bam"
#samtools  index $2"_multimapped_sorted.bam"
#samtools  depth $2"_multimapped_sorted.bam" > $2"_multimapped_sorted.depth"



















