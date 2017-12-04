## Phase 3. Segmenting entire genome based on copy number variation and quantifying them ##
## Result is stored in $o1(output_filename)"_compression.gff" : ##

# sh entire_chrom.sh 	$depth_file_loc 	$cnv_3 		$output_filename &

output_filename=$3
echo "Phase 3 - Segmenting entire genome based on Copy Number Threshold has started" >> $output_filename"_logfile.txt"

rm -rf $3"_tmp.tmp"
rm -rf $3"_compression.gff"

cnv=$2


cat $1/$3"_GCDP.depth" | awk -v cnv="$cnv" 'BEGIN {OFS="\t"} {
											  if($NF/cnv>1)
											  {	
												p=$NF/cnv;
												if(p%1!=0)
												{
													p=(int(p)+1);													
												}
												print $0,p;
												}
											 }'| awk '{if(NR==1) { x=$4;print $1,"\t",$2,"\t",$3,"\t",$4,0} else {print $0,sqrt(($4-x)^2);x=$4 }}' > $3"_tmp.tmp"
												 
												
											  
ul=$(sort  -n -r -k 4,4 $3"_tmp.tmp" | awk '{print $4}' | head -1 )
ll=$(sort -n -k 4,4 $3"_tmp.tmp" |  awk '{print $4}' | head -1 )
getline=$(wc -l $3"_tmp.tmp" | awk '{print $1}')
echo "maximum copy number based on per base calculation is:" $ul " and minimum copy number based on per base calculation is:" $ll >> $output_filename"_logfile.txt"


cat  $3"_tmp.tmp" | awk -v ul="$ul" -v ll="$ll" -v cnv="$cnv" '{if(($4<=ul)&&($4>=ll)) {print $0,sqrt(($2-y)^2); y=$2}}' |  awk -v check="$getline"  '{
													if($6<50)
													{
														if( NR!=check)
														{
															read=read+$3;
															size=size+1;
															cnv=cnv+$4;
															end=$2;
															chrom=$1;
														}
														else
														{
														 copy=cnv/size;
														 															
															if (copy%1!=0)
																{
																	copy=(int(copy)+1);
																}																
															print chrom, "copy_detector", "segment", start,end, ".", "+",".","ID:compressed;average read depth:"read/size";copy_number:"copy";length:"end-start;
															exit;
														}
													}
													else
													{
														if(p!=1)
														{
															start=$2;
															read=$3;
															size=1;
															cnv=$4;
															p=1;
															end=$2;
															chrom=$1;	
														}
														else
														{															
															copy=cnv/size;
															
															if (copy%1!=0)
																{
																	copy=(int(copy)+1);
																}	
															
															print chrom, "copy_detector", "segment", start,end, ".", "+",".","ID:compressed;average read depth:"read/size";copy_number:"copy";length:"end-start;
															start=$2;
															read=$3;
															size=1;
															end=$2;
															cnv=$4;
															chrom=$1;
															
														}
													}
													
												}'  >> $3"_compression.gff"


echo "Phase 3 - Segmenting entire genome based on Copy Number Threshold is completed and result is written in " $3"_compression.gff" >> $output_filename"_logfile.txt"

## Phase 3. Finished ##  