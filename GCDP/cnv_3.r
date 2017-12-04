#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

a=read.table(args[1], as.is=T, header=F)
threshold_0=mean(a$V5)+sd(a$V5*3)
y=paste(toString(args[2]),"_single_genes_read_covg_stat_additional.txt",sep="")

write(c("First Mean=",toString(mean(a$V5)),"First SD=",toString(sd(a$V5)), "First Threshold=",toString(threshold_0)), file=y,ncolumns =5,append = TRUE, sep = "\t")




#nrow(a)
#threshold_0

a2=a[a$V6<=quantile(a$V6,0.25),]
threshold_1=mean(a2$V5)+sd(a2$V5*3)

write(c("Second Mean=" , toString(mean(a$V5)) , "Second SD=" , toString(sd(a$V5)) , "Second Threshold=" , toString(threshold_1)) , file=y,ncolumns =5,append = TRUE, sep = "\t")



#nrow(a2)
#threshold_1
a3=a2[a2$V9<=quantile(a2$V9,0.25),]
#nrow(a3)
threshold_2=mean(a3$V5)+sd(a3$V5*3)

write(c("Third Mean=",toString(mean(a$V5)),"Third SD=",toString(sd(a$V5)),"Third Threshold=",toString(threshold_2)), file=y,ncolumns =5,append = TRUE, sep = "\t")



x=paste(toString(args[2]),"_single_genes_read_covg_stat.txt",sep="")



#threshold_2
#mean(a3$V5)
#sd(a3$V5)
if (nrow(a3)<10) {
	if (nrow(a2)<10){write(c(threshold_0),file=x,ncolumns =1,append = FALSE, sep = "\t")}	
	else {write(c(threshold_1),file=x,ncolumns =1,append = FALSE, sep = "\t")}
	}else {write(c(threshold_2),file=x,ncolumns =1,append = FALSE, sep = "\t")
	}
