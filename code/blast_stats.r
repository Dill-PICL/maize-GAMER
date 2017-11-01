#install.packages("reshape2")
#install.packages("network")
#install.packages("igraph")
#install.packages("rgl")
#library("igraph")
#install.packages("ggplot2")

in_colnames <- c("qseqid", "sseqid", "qlen", "qstart", "qend", "slen", "sstart", "send", "evalue", "bitscore", "score", "length", "pident", "nident", "gaps")

ara_mz_aa <- read.table("../blast_out/ara-mz-aa.txt")
colnames(ara_mz_aa) <- in_colnames
ara_mz_cds <- read.table("../blast_out/ara-mz-cds.txt")
colnames(ara_mz_cds) <- in_colnames

mz_ara_aa <- read.table("../blast_out/mz-ara-aa.txt",header = F,sep = "\t",quote = "")
colnames(mz_ara_aa) <- in_colnames
mz_ara_cds <- read.table("../blast_out/mz-ara-cds.txt")
colnames(mz_ara_cds) <- in_colnames

hist(mz_ara_aa$length/mz_ara_aa$qlen)
head(as.character(mz_ara_aa$qseqid))
head(gsub("_P..","",as.character(mz_ara_aa$qseqid)))
head(gsub("_P..","",as.character(mz_ara_aa$qseqid)))
head(mz_ara_cds$qseqid)
sum(mz_ara_aa$length/mz_ara_aa$qlen>0.8)
sum(mz_ara_aa$length/mz_ara_aa$slen>0.8)

plot(mz_ara_aa$score/max(mz_ara_aa$score),mz_ara_aa$evalue)

plot(mz_ara_aa$length/mz_ara_aa$qlen)

plot(mz_ara_aa[mz_ara_aa$length>4000,]$score,mz_ara_aa[mz_ara_aa$length>4000,]$evalue)
summary(mz_ara_aa[mz_ara_aa$length>1000,]$slen)
summary(mz_ara_aa[mz_ara_aa$length>1000,]$qlen)
sum(mz_ara_aa$evalue<0.001)
head(unique(mz_ara_aa$qseqid))

tmp <- mz_ara_aa[mz_ara_aa$qseqid=="GRMZM2G424981_P01",]
mz_ara_aa[mz_ara_aa$qseqid=="GRMZM2G054378_P01",c("qseqid","sseqid","nident","evalue","score")]
qcov <- round(tmp$length/tmp$qlen*100,2)
scov <- round(tmp$length/tmp$slen*100,2)
tmp <- cbind(tmp,qcov,scov)
tmp

library("reshape2")
library("ggplot2")
tmp_melt<- melt(tmp[,c("sseqid","qcov","scov","length","pident","score","evalue")],id.vars = "sseqid",as.is = T)
head(tmp_melt[tmp_melt$variable=="evalue",])
#plot(tmp$sseqid,tmp$qcov)
#plot(tmp$sseqid,qcov)

#par(mfrow=c(2,2))\
png("img/blast_hits.png",width = 9,height = 5.8,units = "in",res = 300)
gplot <- ggplot(tmp_melt,aes(x=sseqid,y=value,fill=sseqid))
gplot <- gplot + geom_bar(stat="identity")
gplot <- gplot + theme(axis.text.x=element_text(angle = -45, hjust = 0)) + guides(fill=FALSE)
gplot <- gplot + ggtitle("BLAST output for the hits for GRMZM2G424981") + facet_grid(variable~.,scales = "free")
gplot
dev.off()
tmp_melt[tmp_melt$variable=="score",]
tmp$score
tmp
# evalue_trans <- round(-1*log(tmp$evalue,10),2)
evalue_trans
#tmp <- cbind(tmp, evalue_trans)face
tmp$evalue_trans <- evalue_trans
tmp
png("img/evalue.png",width = 9,height = 5.8,units = "in",res = 300)
gplot <- ggplot(tmp,aes(x=sseqid,y=evalue_trans,fill=sseqid))
gplot <- gplot + geom_bar(stat="identity")
gplot <- gplot + theme(axis.text.x=element_text(angle = -45, hjust = 0)) + guides(fill=FALSE)
gplot <- gplot + ggtitle("BLAST output for the hits for GRMZM2G054378")
gplot
dev.off()

tmp$sseqid

# tmp$qseqid <- "ZM"
# tmp$sseqid <- paste("AT",1:dim(tmp)[1],sep = "")
write.table(tmp,file = "img/pident.txt",row.names = F,col.names = T,quote = F)
# 
# tmp <- mz_ara_aa[mz_ara_aa$qseqid=="GRMZM2G054378_P01" & mz_ara_aa$pident>=40,c("qseqid","sseqid","evalue")]
# tmp
# tmp$qseqid <- "ZM"
# tmp$sseqid <- paste("AT",1:dim(tmp)[1],sep = "")
# write.table(tmp,file = "img/evalue.txt",row.names = F,col.names = T,quote = F)
# 
# mz_ara_aa[mz_ara_aa$nident/mz_ara_aa$qlen*100 > 60 & mz_ara_aa$nident/mz_ara_aa$qlen*100 <90,]
head(unique(mz_ara_aa$qseqid),10)
# mz_ara_aa[mz_ara_aa$qseqid=="GRMZM2G424981_P01",]

