#!/usr/bin/env Rscript





args <- commandArgs(trailingOnly = TRUE)
a=read.table(args[1], as.is=T, header=F)
cnv=args[2]
cnv=as.numeric(cnv)
rc_mean=mean(a$V4)
rc_sd=sd(a$V4)
rc_max=max(a$V4)
diff_sd=sd(a$V5)


a=as.matrix(a)
geneid=a[1,1]
chromosome=a[1,2]
starting=a[1,3]
length_of_gene=nrow(a)
ending=a[length_of_gene,3]
copy_number=(rc_mean)/cnv
if (copy_number%%1!=0) {copy_number=as.integer((copy_number+1),digits=0)}


write(c(geneid,chromosome,starting,ending,length_of_gene,rc_mean,rc_sd,rc_max,diff_sd,rc_mean/cnv,copy_number),file="./cords_based_cnv.txt",ncolumns =11,append = TRUE, sep = "\t")







