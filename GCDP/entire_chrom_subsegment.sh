#!/bin/bash
#sh entire_chrom_subsegment.sh 		$output_filename &

output_filename=$1

rm -rf tmp_6.tmp
rm -rf $1"_high_copy_cords" 
rm -rf $1"_result.txt"





cat $1"_compression.gff" | grep -v -w "copy_number:2" | awk '{print $1,$4,$5}' > $1"_high_copy_cords" 
cat $1"_high_copy_cords" | while read line 
do 
echo $line | awk '{print $0}' > tmp_6.tmp
chrm=$(cat tmp_6.tmp | awk '{print $1}')
start=$(cat tmp_6.tmp | awk '{print $2}') 
end=$(cat tmp_6.tmp | awk '{print $3}') 
 
grep -w "$chrm" $1"_tmp.tmp" | awk -v start="$start" -v end="$end" '{
													if(($2>=start)&&($2<=end))
													{
														 
														 if(p!=1)
														 {
															cord1=$2;
															cord2=$2;
															p=1;
															size=1;
															copy=$4;
															
														 }
														else
														{
															if($5<=2)
															{
																
																size=size+1;
																cord2=$2;
																copy=copy+$4;
																if($2==end)
																{
																	print $1,cord1,cord2,int(copy/size),cord2-cord1;
																	
																	
																	exit;
																}
																
																
																
															}
															else
															{
																print $1,cord1,cord2,int(copy/size),cord2-cord1;
																
																cord1=$2;
																cord2=$2;
																copy=$4;
																size=1;
																
															}
														}
													}
													}' >> $1"_result.txt"
													
done



a=1
echo "Phase 4-almost done" >> $output_filename"_logfile.txt"

cat $1"_compression.gff" |  grep -w "copy number:2" | tr ":" "\t" | awk '{print $1,$4,$5,$15,$NF}' | sed 's/length//g' | sed 's/;//g' > $1"_low_copy_cords"


cat $1"_low_copy_cords" $1"_result.txt" | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$4,$5}' | sort -k 1,1 -k 2,3n | awk -v id="$a" ' { if ( ($3-$2) >=10)print $1,"copy_detector","segment",$2,$3,".","+",".","ID:"id";copy_number:"$4";length:"$5;id=id+1}' > $1"_compression_final.gff"






rm -rf tmp_6.tmp
rm -rf $1"_tmp.tmp"
rm -rf $1"_result.txt"
rm -rf $1"_high_copy_cords"
rm -rf $1"_low_copy_cords"
 
echo "Phase 4 - Subsegmenting entire genome is completed, result written in " $1"_compression_final.gff" >> $output_filename"_logfile.txt"

																
