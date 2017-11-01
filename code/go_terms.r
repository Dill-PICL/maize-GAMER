#chooseCRANmirror(graphics = getOption("menu.graphics"))
#chooseBioCmirror(graphics = getOption("menu.graphics"))
#source("http://bioconductor.org/biocLite.R")
#biocLite("GO.db")

library(GO.db) #load the library for GO database
setwd("/media/research/go_annotation/pipeline/arabidopsis/step4") # set the working dir

go_freq = read.table("arab_go.list") #read the table with GO terms
a <- subset(go_freq) # get a subset of GO terms

bpa <- as.list(GOBPANCESTOR) #Load the Biological process ancestor db
mfa <- as.list(GOMFANCESTOR) # Load the Molecular function ancestor db
cca <- as.list(GOCCANCESTOR) #load the cellular component ancestor db

bpl <- 0
bpl2 <- 0
for(go_term in a$V1){
  if(bpa[go_term] != "NULL"){
    bpls = paste(as.list(bpa[go_term]),sep=",")
    bpl2 <- c(bpl2,bpls)
    bpl <- c(bpl,go_term)
  }
}

mfl<-0
mfl2 <-0
for(go_term in a$V1){
  if(mfa[go_term] != "NULL"){
    mfls = paste(as.list(mfa[go_term]),sep=",")
    mfl2 <- c(mfl2,mfls)
    mfl <- c(mfl,go_term)
  }
}

ccl<-0
ccl2 <-0
for(go_term in a$V1){
  if(cca[go_term] != "NULL"){
    ccls = paste(as.list(cca[go_term]),sep=",")
    ccl2 <- c(ccl2,ccls)
    ccl <- c(ccl,go_term)
  }
}



write.table(x=bpl2,file="gene_go_children/bplf.txt",row.names=bpl,sep="\t");
write.table(x=mfl2,file="gene_go_children/mflf.txt",row.names=mfl,sep="\t");
write.table(x=ccl2,file="gene_go_children/cclf.txt",row.names=ccl,sep="\t");