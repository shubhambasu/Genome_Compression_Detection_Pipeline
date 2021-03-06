#  A novel pipeline for detecting genomic compressions caused by whole genome misassembly.

## Synopsis

Genomic Compression Detection Pipeline (GCDP) is a pipeline designed to efficiently detect and estimate genomic compressions in 		whole genome sequence created by genome misassembly. Genomic compressions are assembly artifacts characterized by collapse or merge of near identical repeats in genome sequence. GCDP uses Read Depth Coverage (R.D.C) generated by mapping of pair-end (or single end) short reads (example: Illumina) to the reference genome, for locating these problematic regions across the entire genome sequence as well as user-defined gene/genomic co-ordinates. Currently its designed for haploid genomes only and requires co-ordinates of user-defined single-copy genes/genomic segments for normalizing background read coverage and calculating Compression Detection Threshold required for detecting and estimating compressions. It runs in UNIX command prompt as well as on cluster (HPC).

## Workflow

![gcdp_pipeline_workflow](https://user-images.githubusercontent.com/4494942/33569649-4fad280c-d8f8-11e7-83c1-9b3966a35d62.png)

	The pipeline works in 2 steps :
	(i)  Mapping reads to reference genome sequence and generating depth file from uniquely mapped reads. 
	(Currently works for pair-end reads only)
	(ii) Using depth files generated from step (i) and user-provided single copy gene/ genomic co-ordinates
	to identify and estimate genomic compressions across entire genome sequence as well as specified genomic co-ordinates.
	
	User can skip step (i) by providing pre-mapped depth file generated from mapping either single or pair-end reads to the 
	reference genome sequence. [See Input files for details] 
	
	Step (ii) consists of 4 phases:
	Phase 1. This step calculates average read depth coverage across all user-provided single copy gene/genomic segments and uses 
	its distribution and deviation to filter out false positives and background noise. It further generates Compression Detection 
	Threshold, a value corresponding to 3 times standard deviation of average read depth, which is used in subsequent phases for
	calculation and estimation of compressions. 
	
	Phase 2. In this step, compressions of user-provided genomic co-ordinates are calculated using Compression Detection Threshold from
	phase 1. This step is particularly useful when it is required to calculate copy number of specific genes or intergenic sequences that
	are believed to be compressed in the given reference sequence. This phase is optional and runs parallelly with phase 3 & 4.  
	
	Phase 3. The Compression Detection Threshold is used to estimate compression / copy number for each base across entire genome sequence
	to seperate regions with detected compressions from non-compressed regions. It works by clustering these compressed regions and 
	defining boundaries between segments that are atleast 50bp apart (by default setting) . This phase provides genomic segments that represent 
	compressions with a wider genomic resolution and copy number which has been averaged over relatively longer sequence length. 
	
	Phase 4. This step uses the output from phase 3 and sharpens the resolution of the detected compressions by sub-segmenting the 	
	compressed genomic segments based on difference in copy number ( copy number >2 by default setting)  between 2 consecutive bases. Thus it redefines boundaries of compressed
	segments detected from previous step and generates a new list of genomic co-ordinates that represents genome locations that are 
	enriched in compressions relative to its adjacent regions.   

## Prerequisites

	Following programs are required for GCDP to run :
	(i)   SAMTools 
	(ii)  BWA-MEM 
	(iii) R (V3.1 or above)
	
	All of the above should be made available in the PATH BEFORE running the pipeline. To do that, use : 
	export PATH=$PATH:/path/to/folder_containing_program 	
	e.g: If R is located at usr/local/apps/R/3.3.1/bin/R, use
	export PATH=$PATH:/usr/local/apps/R/3.3.1/bin

## Input files
	
	The following files will be required to run GCDP: 
	For step (i) : 			 1.	reference_genome.fasta 
				         2.	pair_end_read_1.fastq 
				         3.	pair_end_read_2.fastq 
				         4.	chromosome_list.txt
				  
	For step (ii): 			 1. 	depth_file.depth 
				         2. 	chromosome_list.txt
				         3. 	single_copy_co-ordinates.txt 
				         4. 	all_co-ordinates.txt
				   
	Location and name of files required in step (ii) must be written in parameter.file [see Details of input files] 
	The parameter.file is the only file required for running this step.
	
## Details of input files:
	
	For Step (i):
	reference_genome.fasta: Genome sequence in fasta format for which the genomic compressions are calculated. Please only include 
	chromosomes and not broken contigs for optimum use.
	pair_end_read_1.fastq : Forward reads in fastq format. 
	pair_end_read_2.fastq : Reverse reads in fastq format. 
	Reads should be ideally clean ( using trimmomatic for example ) before using.If using multiple libraries, they can be concatenated into total forward and reverse read fastq files.							                   
    
	User can skip all the above files required for step (i) if starting with pre-mapped depth file
	
	For Step (ii):
	depth_file.depth: 	        Depth file generated from step (i) or the one generated by user from mapping single/pair-end reads to reference_genome.fasta. [See Running GCDP for details]
	single_copy_co-ordinates.txt:	A tab delimited co-ordinates of genes / genomic segments believed to be present in single copy in genome sequence (Format: Geneid Chromosome Start End)
	all_co-ordinates.txt:	        A tab delimited co-ordinates of genes / genomic segments for which compressions need to be calculated (optional)(Format: Geneid Chromosome Start End)
	chromosome_list.txt:	        A text file listing name of chromosomes (one in each line). Make sure the name matches the header    representing chromosomes in input reference_genome.fasta file.
	parameter.file:			A text file detailing name and locations of all the above files required for running step (ii)
	
	Format of parameter file: 
	output_filename=prefix	# same prefix as used during step (i) or using user_provided_depth file #
	cords=/path/to/all_co-ordinates.txt # leave it blank if co-ordinate based compression detection is not required #
	depth_file_loc=/path/to/folder_containing_all_depth_files # folder that contains depth files generated from step (i)
	single_copy_gene_cords=/path/to/single_copy_co-ordinates.txt
	chromosome_list=/path/to/chromosome_list.txt
		
	                [See Example for more details]								
		
##  Brief description of GCDP script files
	
	Scripts required for step (i) & (ii) are located inside DEPTH and GCDP folders respectively. 
	Main file inside DEPTH is depth_maker.sh which is used for performing step (i) to generate depth file following mapping of 
	pair_end_read_1/2.fastq reads to reference_genome.fasta and filtering out reads that are unmapped or mapped to more than one 
	location. 
	Main file inside GCDP is gcdp.sh which detects and estimates compression in entire reference_genome.fasta (using entire_chrom.sh
	& entire_chrom_subsegment.sh) as well as those provided in all_co-ordinates.txt (using cords.sh). Histogram.sh can be used in the end 
	to generate read depth based histograms highlighting regions of detected compressions [ See Running GCDP for details ] 
	
## Running GCDP 

	Make sure to use same prefix throughout the entire pipeline. (See Example for details). Its a good practice to use the following commands on shell scripts to clean files from un-necessary characters before running.
	
		$ dos2unix *.sh
		$ dos2unix *.r
	
	GCDP runs in 2 steps. User can skip step (i) if pre-mapped depth file is already present. Run chromosome_splitter.sh in this case ( See below). 
	
	Step (i): For running in cmd line, from DEPTH/ and use the following command : 
		$ sh depth_maker.sh /path/to/reference_genome.fasta /path/to/pair_end_read_1.fastq /path/to/pair_end_read_2.fastq chromosome_list.txt prefix
	
		User with pre-mapped depth file will require to do the following: 
		1. Rename the depth file into prefix_GCDP.depth
		2. Copy and run chromosome_splitter.sh in the same folder containing the depth file using following command:
			$ sh chromosome_splitter.sh chromosome_list.txt prefix_GCDP.depth
	
	Step (ii): For running in cmd line, from GCDP/ use the following command:
			$ sh gcdp.sh parameter.file 
		
        For generating histogram using the resulting compression_final.gff file, use the following command: 
	
			$ sh histogram.sh depth_file_loc chromosome_list  cnv compression.gff prefix 
	##  cnv can be located in output file named prefix_single_genes_read_covg_stat.txt (See Output for details)
	
	For running the pipeline in cluster, use DEPTH/main_depth.sh for step (i) and GCDP/main_gcdp.sh for step (ii). 
	Make sure to export PATH (or loading modules ) to SAMTools, BWA and R inside the shell script before submitting 
	the job using following command: 
			$ qsub main_depth.sh 
			$ qsub main_gcdp.sh	
		
##  Output files 

        The most important output files / folders of user interest are explained below:

	Output from running Step (i): 1. Folder named prefix_bam_chrom_files which contains required depth files for running step (ii)
	                              2. prefix_logfile.txt : Logfile detailing the resulting statistics from running step (i)    
	Output from step (ii): 1. prefix_single_genes_stat.txt:  A tab delimited format showing gene-id start end chromosome average(of mapped reads)  standard_deviation(of mapped reads) median(of mapped reads) maximum_number_of_reads_mapped standard_deviation_of difference_in_reads_mapped_betwee_two_conseuctive_bases
			       2. prefix_single_genes_read_covg_stat.txt: Compression Detection Threshold value.This is the output from phase 1.
			       3. prefix_all_cords_result.txt: Tab delimited format giving estimated compression / copy number of user-provided gene/genomic segments. (Format: geneid chromosome start end length average_read_depth copy_number). This is the output from phase 2.
			       4. prefix_compression.gff : A gff file detailing co-ordinates and estimates of compression across entire genome sequence based on relative distance (consecutive segments seperated by >50bp) . This is the output from phase 3.
			       5. prefix_compression_final.gff: A gff file detailing co-ordinates and estimates of compression across entire genome sequence based on relative difference in compression (copy number >2). This is output of phase 4. 
			       6. prefix_logfile.txt: A logfile detailing the statistics from running step (ii) of GCDP. 
			       
	Additionally, if running histogram.sh, the histogram files are generated for each chromosome with prefix _unique_sorted.depth_cnv.png and can be used for visualization purpose. 		      
			       
## Example Files

	The pipeline contains following files & folders in the SAMPLE/ folder. 
	
	sample_depth=folder containing a sample depth file generated from mapping reads to chromosome II & III of T.gondii VEG genome sequence VEG_genome.depth 
	sample_VEG_all_genes.txt= Tab delimited text file listing some randomly selected genes from T.gondii VEG genome
	sample_VEG_single_copy_toxo.txt= Tab delimited text file listing genes that are expected to be in single copy in T.gondii VEG genome
	chromosome_list.txt= Text file listing all 14 chromosomes from T.gondii VEG genome sequence. 
	
	## Cleaning up files
	 $ dos2unix *.sh 
	 $ dos2unix  *.r 
	 
	 ## Generating depth files from pre-mapped depth file
		 mv VEG_genome.depth sample_VEG_genome_GCDP.depth
	 
		 $ sh chromosome_splitter.sh chromosome_list.txt sample_VEG_genome
	 
	 ##  Writing parameter.file 
	 
	 output_filename=sample_VEG_genome
	 cords=./SAMPLE/sample_VEG_all_genes.txt
	 depth_file_loc=./SAMPLE/sample_depth 
	 single_copy_gene_cords=./SAMPLE/sample_VEG_single_copy_toxo.txt 
	 chromosome_list=./SAMPLE/chromosome_list.txt
	
	 ## running GCDP Step (ii) 
	 
	 $ sh gcdp.sh parameter.file
	 
	 ## Checking results 
	 
	 The following files will be generated out of which sample_VEG_genome_compression_final.gff will 
	 provide a gff file detailing genomic co-ordinates with compressions detected by GCDP [Check Output Files for reference ]
	 
	 sample_VEG_genome_single_genes_stat.txt
	 sample_VEG_genome_single_genes_read_covg_stat.txt
	 sample_VEG_genome_single_genes_read_covg_stat_additional.txt
	 sample_VEG_genome_compression.gff
	 sample_VEG_genome_compression_final.gff
	 sample_VEG_genome_logfile.txt

## Author
* **Shubham Basu** - *Initial work* - (https://github.com/shubhambasu)

## References
Li, H., B. Handsaker, A. Wysoker, T. Fennell, J. Ruan, N. Homer, G. Marth, G. Abecasis and R. Durbin (2009). "The Sequence Alignment/Map format and SAMtools." Bioinformatics 25(16): 2078-2079.

Li, H. and R. Durbin (2009). "Fast and accurate short read alignment with Burrows-Wheeler transform." Bioinformatics 25(14): 1754-1760.

	
	
	

	 
	 
	
	
	
	


	
	

			       
			     

			       
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
