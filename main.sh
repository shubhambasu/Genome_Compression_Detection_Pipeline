#!/bin/bash

# Usage: qsub main.sh

# Putting cluster-based commands here

#PBS -N depth_maker
#PBS -q batch
#PBS -l nodes=1:ppn=12:jcknode
#PBS -l walltime=480:00:00
#PBS -l mem=10gb
cd $PBS_O_WORKDIR
#------------------------------------------------------

# UNIX file format check 
dos2unix -q *.sh
dos2unix -q *.txt
#------------------------------------------------------


# Export Path to BWA and SAMtools here 
export PATH=$PATH:/usr/local/apps/samtools/1.3.1/bin
export PATH=$PATH:/usr/local/apps/bwa/0.7.15
#------------------------------------------------------

# Path to reference_genome.fasta and pair_end_reads.fastq 
DIR1=/lustre1/sb16478/escratch4_from_zcluster/sb16478/files/ToxoDB-27_TgondiiME49_Genome/only_chrom
DIR2=/lustre1/sb16478/escratch4_from_zcluster/sb16478/files/illumina
#------------------------------------------------------


sh depth_maker.sh ${DIR1}/ToxoDB-27_TgondiiME49_Genome_onlychrom.fasta ${DIR2}/all_R1_P_F.fastq ${DIR2}/all_R2_P_F.fastq chromosome_list.txt ME49 