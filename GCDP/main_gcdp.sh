#!/bin/bash

# Usage: qsub main.sh 

# Putting cluster-based commands here

#PBS -N gcdp
#PBS -l nodes=1:ppn=1:jcknode
#PBS -q batch
#PBS -l walltime=480:00:00
#PBS -l mem=20gb

cd $PBS_O_WORKDIR


# Export Path to R here 
export PATH=$PATH:/usr/local/apps/R/3.3.1/bin
#------------------------------------------------------


# UNIX file format check 
dos2unix -q *.sh
dos2unix -q *.r
dos2unix -q *.txt
#------------------------------------------------------

# Cleaning Residual Files  
rm -rf *.tmp
#------------------------------------------------------


sh gcdp.sh parameter.file 
