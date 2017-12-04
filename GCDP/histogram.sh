#!/bin/bash
### Generating histogram with read pileup highlighting detected problematic regions ###

# Usage: sh histogram.sh depth_file_loc chromosome_list  cnv compression.gff output_filename #

module load R/3.3.1
rm -rf tmp_4

output=$5

i6=$1/$5"_GCDP.depth"
chromosome_list=$2
cnv=$3
limit=8030


cat $chromosome_list | while read line
do 
echo $line | awk '{print $0}' > tmp_4
chrm=$(cat tmp_4 | awk '{print $1}') 
#grep $chrm $i6 > $chrm".depth"
 
#grep -w $chrm  $4 | awk '{for (i = $4; i <= $5; i++) print i}' > $chrm"_tmp"
echo "histogram of" $chrm "started" 
head $1/$chrm"_"*"_unique_sorted.depth"
Rscript --vanilla  histogram.r $1/$chrm"_"*"_unique_sorted.depth" $chrm"_tmp" $limit $cnv  &
wait
echo "histogram of" $chrm "finished" 
mv $1/$chrm"_"*"_unique_sorted.depth_cnv.png" ./$chrm"_"$output"_cnv.png"
done

#rm -rf $chrm"_tmp"
wait
echo "All histograms generated" 

