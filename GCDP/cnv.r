#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)



a=read.table(args[1], as.is=T, header=F)

rc_mean=mean(a$V4)
rc_median=median(a$V4)
rc_sd=sd(a$V4)
rc_max=max(a$V4)
diff_sd=sd(a$V5)


a=as.matrix(a)

geneid=a[1,1]
start=a[1,3]
n=nrow(a)

end=a[n,3]
chr=a[1,2]
x=paste(toString(args[2]),"_single_genes_stat.txt",sep="")

write(c(geneid,chr,start,end,rc_mean,rc_sd,rc_median,rc_max,diff_sd),file=x,ncolumns =9,append = TRUE, sep = "\t")







