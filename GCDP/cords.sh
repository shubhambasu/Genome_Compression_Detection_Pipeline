#!/bin/bash


cnv=$2				

output_filename=$4

	cat $3 | while read line
	do
	echo $line | awk '{print $0}' > $3"_tmp_3.tmp"
	seqid=$(cat $3"_tmp_3.tmp" | awk '{print $1}') 
	chrm=$(cat $3"_tmp_3.tmp" | awk '{print $2}')
	starting=$(cat $3"_tmp_3.tmp"| awk '{print $3}')
	ending=$(cat $3"_tmp_3.tmp" | awk '{print $4}') 

	echo "Phase 2: Calculating compression/copy number of " $seqid " located in " $chrm >> $output_filename"_logfile.txt"


	cat $1   | awk  -v cnv="$cnv" -v seqid="$seqid"  -v chrm="$chrm" -v starting="$starting" -v ending="$ending" '{ 
																																									if(($2>=starting)&&($2<=ending)) 
																																									{	
																																									  read=read+$3;
																																									  ln=ln+1;
																																									}
																																									else
																																									{
																																									   if($2>ending)
																																									   {
																																										 avg=read/ln;
																																										 copy=avg/cnv;
																																										 if (copy%1!=0)
																																										 {
																																											copy=(int(copy)+1);
																																										 }
																																										print seqid,chrm,starting,ending,ln,avg,copy;
																																										copy=0;
																																										avg=0;
																																										ln=0;
																																										read=0;
																																										exit;
																																									   }
																																									   
																																										
																																									}
																																									}' >> $4"_all_cords_result.txt"
																		
																																											
																																									 
																																									 

	echo "Phase 2: Compression/copy_number of " $seqid " located in " $chrm " finished and saved in " $4"_all_cords_result.txt" 	>> $output_filename"_logfile.txt"																																						
	done


	rm $3"_tmp_3.tmp"
	rm $3

	y=$(wc -l $4"_all_cords_result.txt" | awk '{print $1}')

	if [[ $y -eq $5  ]] ; then {


		echo "Compression/copy_number of all user-provided genes/segments is written in" $4"_all_cords_result.txt" >> $output_filename"_logfile.txt"
		rm -rf tmp_5.tmp
		echo "Phase 2 - Compression/copy_number of all user-provided genes/segments is completed"  >> $output_filename"_logfile.txt"
		
	}
	fi ;
	

### Phase 2. Finished  ###
