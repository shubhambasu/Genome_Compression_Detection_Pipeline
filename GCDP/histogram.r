#!/usr/bin/env Rscript

#Rscript --vanilla  histogram.r $1/$chrm"_"*"_unique_sorted.depth" $chrm"_tmp" $limit $cnv  &


args <- commandArgs(trailingOnly = TRUE)
a=read.table(args[1], as.is=T, header=F)
b=read.table(args[2], as.is=T, header=F)
head(a) 
head(b)
limit=as.numeric(args[3])
threshold=b$V1
cnv_threshold=as.numeric(args[4])
x=paste(toString(args[1]),"_cnv.png",sep="")
png(file=x,width=1200,height=1200)
plot(a$V2,a$V3, las=1, pch=20, col="white", xlab="Chromosomal Position (Mb)", ylab="Depth",ylim=c(0,limit))
arrows(a$V2,0,a$V2,a$V3, length=0, col=ifelse((a$V2 %in% threshold == TRUE), "red", "forestgreen"))
abline(h=cnv_threshold)
dev.off()
