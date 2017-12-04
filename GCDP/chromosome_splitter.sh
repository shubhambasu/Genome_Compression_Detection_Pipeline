#!/bin/bash 

# Make sure to rename yout depth file to prefix_GCDP.depth
# Usage: sh chromosome_splitter.sh	chromosome_list.txt 	depthfile	

rm -rf tmp
cat $1 | while read line 
do 
echo $line > tmp 
chrom=$(cat tmp | awk '{print $0}')

grep -w "$chrom" $2 > $chrom"__unique_sorted.depth"
	if	[[	-s $chrom"__unique_sorted.depth" ]]; then {
	echo $chrom "detected in depth file, generating" $chrom"__unique_sorted.depth"
	}
	else {
	rm $chrom"__unique_sorted.depth"
	}; 
	fi
done 
rm -rf tmp
echo "Splitting of" $2 "by chromosomes is completed"