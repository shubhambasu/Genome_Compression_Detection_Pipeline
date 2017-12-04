#!/bin/bash


# Parameter file check [See Readme for details]
echo "Checking parameter file....." 


output_filename=$(grep -w "output_filename" $1 | tr "=" "\t" | awk '{print $NF}')
if [[ -z $output_filename ]] ; then {
    echo "output_filename not provided, please provide a prefix, program exiting.. [ See Readme on using correct prefix for output files]"
    exit 1
        } fi;
rm -rf $output_filename*
echo "User-provided prefix of output filename: "$output_filename >> $output_filename"_logfile.txt"
echo "Logfile saved as "$output_filename"_logfile.txt" >> $output_filename"_logfile.txt"


depth_file_loc=$(grep -w "depth_file_loc" $1 | tr "=" "\t" | awk '{print $NF}')
if [[ ! -d $depth_file_loc ]] ; then {
    echo "Can't locate the depth file containing folder, program exiting..."
    exit 1
	} fi;
echo "Path and root folder containing required depth files is provided as: " $depth_file_loc >> $output_filename"_logfile.txt"


single_copy_gene_cords=$(grep -w "single_copy_gene_cords" $1 | tr "=" "\t" | awk '{print $NF}')
if [[ ! -s $single_copy_gene_cords ]] ; then {
    echo "Can't locate file containing co-ordinates of single copy genomic co-ordinates, program exiting..."
    exit 1
	} fi;
echo "User-provided file containing single copy genomic co-ordinates is: " $single_copy_gene_cords >> $output_filename"_logfile.txt"
dos2unix -q $single_copy_gene_cords


chromosome_list=$(grep -w "chromosome_list.txt" $1 | tr "=" "\t" | awk '{print $NF}')
if [[ ! -s $chromosome_list ]] ; then {
    echo "Can't locate file containing list of chromosomes of given reference genome sequence, program exiting..."
    exit 1
	} fi;
echo "Chromosome list is provided in: " $chromosome_list >> $output_filename"_logfile.txt"


cords=$(grep -w "cords" $1 | tr "=" "\t" | awk '{print $NF}')
if [[ -s $cords ]]; then { 
	echo "User-provided co-ordinates of genomic segments for which compressions is calculated: " $cords >> $output_filename"_logfile.txt"
	}
else {
	
	echo "User didn't provide or can't locate file containing gene or genomic co-ordinates, Phase 2 will be skipped !" >> $output_filename"_logfile.txt"
	}
	fi ;


echo "Parameter file checking done !" >> $output_filename"_logfile.txt"
echo "GCDP started!" >> $output_filename"_logfile.txt"
#------------------------------------------------------



# Phase 1: Calculation of background read depth and Copy Number Threshold based on reads mapped to 
#          user-provided single copy genomic co-ordinates. [See Readme for details]

echo "Phase 1 - Calculation of Copy Number Threshold from user-provided" $single_copy_gene_cords " has started" >> $output_filename"_logfile.txt"

# Phase 1a: This step calculates average read depth and other critical statistics of reads mapped to 
#           genomic co-ordinates provided in single_copy_co-ordinates.txt

cat $single_copy_gene_cords | while read line
do
echo $line | awk '{print $0}' > tmp_2.tmp

geneid=$(cat tmp_2.tmp | awk '{print $1}') 
chrm=$(cat tmp_2.tmp | awk '{print $2}')
starting=$(cat tmp_2.tmp | awk '{print $3}')
ending=$(cat tmp_2.tmp | awk '{print $4}')
files=(${depth_file_loc}/$chrm"_"*"_unique_sorted.depth")

if [ -e "${files[0]}" ]; then {


	cat ${depth_file_loc}/$chrm"_"*"_unique_sorted.depth" | awk  -v geneid="$geneid"  -v chrm="$chrm" -v starting="$starting" -v ending="$ending" '{ 
																																									if(($2>=starting)&&($2<=ending)) 
																																									{
																																										if(p!=1)
																																										{
																																											x=$3;
																																											p=1;
																																											print geneid,chrm,$2,$3,$3-$3;
																																										}
																																										else
																																										{
																																											print geneid,chrm,$2,$3, $3-x;
																																											x=$3;
																																										}
																																									}
																																									else 
																																									if ($2>ending) { exit }}' | sed 's/-//'> ./$geneid".txt" 
													

											
													
	
	Rscript --vanilla  cnv.r $geneid".txt" $output_filename 
	rm $geneid".txt"
}
else 
{ 
	echo "Can't locate" $geneid "in given depth file" >> $output_filename"_logfile.txt"
}
fi;
done
echo "Phase 1 - Calculation of background coverage from user-provided" $single_copy_gene_cords "is written in " $output_filename"_single_genes_stat.txt" >> $output_filename"_logfile.txt"

# Phase 1b: This step performs statistical analysis based on standard deviation and distribution of read coverage across single copy genomic co-ordinates and calculate 
#           Copy Number Threshold value based on quantile range. The Copy Number Threshold is used for calling compressions across entire genome as well as user-provided genomic co-ordinates

Rscript --vanilla  cnv_3.r $output_filename"_single_genes_stat.txt" $output_filename
cnv_3=$(cat $output_filename"_single_genes_read_covg_stat.txt" | awk '{ print $0}')

echo "Copy Number Threshold calculated from background read coverage statistics is: " $cnv_3 >> $output_filename"_logfile.txt"
echo "Copy Number Threshold is written in file "$output_filename"_single_genes_read_covg_stat.txt" >> $output_filename"_logfile.txt"
echo "Additional statistics from Copy Number Threshold calculation are written in file "$output_filename"_single_genes_read_covg_stat_additional.txt" >> $output_filename"_logfile.txt"
echo "Phase 1 - Calculation of Copy Number Threshold from user-provided" $single_copy_gene_cords " has ended" >> $output_filename"_logfile.txt"

rm -rf tmp_2.tmp
#------------------------------------------------------



# Phase 2. Calculating Copy number of user provided genes/genomic segments ( if provided ) 

if [[ -s $cords ]]; then { 
	echo "Phase 2 - Calculating compression/copy_number of genomic segments provided in " $cords " has started" >> $output_filename"_logfile.txt"

	cat $output_filename"_single_genes_stat.txt" | awk '{print $2}' | sort | uniq > $output_filename"_depth_file_provided.tmp"
	
	grep -w -f $output_filename"_depth_file_provided.tmp" $cords > $output_filename"_avail.tmp"
	grep -v -w -f $output_filename"_depth_file_provided.tmp" $cords | awk '{print $1}' > $output_filename"_unavailable_read_coverage"
	if [[ -s $output_filename"_unavailable_read_coverage" ]]; then { 
												echo "IDs of gene/genomic segments for which read coverage data is unavailable are written in:" $output_filename"_unavailable_read_coverage" >> $output_filename"_logfile.txt"
											}
										else {
												rm -rf $output_filename"_unavailable_read_coverage"
											}
											fi;
	x=$(wc -l $output_filename"_avail.tmp" | awk '{print $1}')
	
	cat $chromosome_list | while read line 
	do 
		echo $line | awk '{print $0}' > tmp_5.tmp
		chrom=$(cat tmp_5.tmp | awk '{ print $0}' ) 
		grep -w "$chrom"  $output_filename"_avail.tmp" > $chrom"_gene_list.tmp"
		
		if [[ -s $chrom"_gene_list.tmp" ]] ; then {
														
													sh cords.sh ${depth_file_loc}/$chrom"_"*"_unique_sorted.depth" $cnv_3 $chrom"_gene_list.tmp" $output_filename $x  &
													}
		else
													{
																				
													rm $chrom"_gene_list.tmp"
													}
													fi ;
	
	done	
	rm -rf tmp_5.tmp
	rm -rf $output_filename"_avail.tmp"
	rm -rf $output_filename"_depth_file_provided.tmp"	
	}
	fi;
#------------------------------------------------------



# Phase 3. Segmenting entire genome based on Copy Number Threshold and boundary >50bp (Default)
 
sh entire_chrom.sh $depth_file_loc $cnv_3 $output_filename 
wait
#------------------------------------------------------



# Phase 4. Subsegmenting entire genome based on Copy Number Threshold difference >2 (Default)
echo "Phase 4 - Subsegmenting entire genome has started" >> $output_filename"_logfile.txt"
sh entire_chrom_subsegment.sh $output_filename 
wait

echo "Detection of compressions across entire genome is finished, please check back to to confirm completion of Phase 2 if applicable" >> $output_filename"_logfile.txt"
#------------------------------------------------------