library("data.table")
library("GO.db")

clean_gramene <- function(infile,outfile){
    raw_data <- read.table(infile,header = T,sep = "\t",as.is = T)
    raw_go <- raw_data[raw_data$database == "GO",]
    raw_go$transcript <- gsub("_[TP][0-9]+","",raw_go$transcript)
    raw_go$transcript <- gsub("FG[TP]","FG",raw_go$transcript)
    head(raw_go)
    colnames(raw_go)[c(1,3)] <- c("gene_id","go_id")
    out_dt <- data.table(raw_go)
    setkeyv(out_dt,c("gene_id","go_id"))
    write.table(raw_go[,c(1,3)],outfile,sep="\t",quote = F,row.names = F)
}
    