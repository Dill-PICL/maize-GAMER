library("data.table")
library("reshape2")

if(F){
    infile = pannzer_in
    outfile = pannzer_out
}


clean_fanngo <- function(infile,outfile){
    scores <- read.table(infile,header=T,as.is = T)
    score_dt <- data.table(scores)
    setkeyv(score_dt,c("gene_id","go_id"))
    score_uniq <- score_dt[,list(score=min(score)),by=list(gene_id,go_id)]
    out_dir <- dirname(outfile)
    ifelse(!dir.exists(out_dir),dir.create(out_dir),print("folder exists"))
    write.table(score_uniq,outfile,quote = F,sep = "\t",row.names = F,col.names = T)
}

clean_argot2 <- function(infile,outfile){
    raw_data <- read.table(infile,header = T,sep = "\t")
    raw_data$Sequence <- gsub("_P[0-9]+","",raw_data$Sequence)
    raw_data$Sequence <- gsub("FGP","FG",raw_data$Sequence)
    raw_out <- cbind(raw_data$Sequence,as.character(raw_data$GO.ID),as.character(raw_data$Aspect))
    colnames(raw_out) <- c("gene_id","go_id","aspect")
    raw_out_dt <- data.table(raw_out)
    setkeyv(raw_out_dt,c("gene_id","go_id"))
    out_filt <- unique(raw_out_dt)
    out_dir <- dirname(outfile)
    ifelse(dir.exists(out_dir),print("Directory Already Exisits"),dir.create(out_dir,recursive = T))
    write.table(out_filt,outfile,quote = F,sep = "\t",row.names = F,col.names = T)
}

clean_pannzer <- function(infile,outfile){
    raw_data <- read.table(infile,header = T,sep = "\t")
    colnames(raw_data) <- c("gene_id","go_id","score")
    raw_data$gene_id <- gsub("_P[0-9]+","",raw_data$gene_id)
    raw_data$gene_id <- gsub("FGP","FG",raw_data$gene_id)
    hist(raw_data$score)
    
    raw_out_dt <- data.table(raw_data)
    setkeyv(raw_out_dt,c("gene_id","go_id"))
    out_filt <- unique(raw_out_dt[score>=0.40])
    out_dir <- dirname(outfile)
    ifelse(dir.exists(out_dir),print("Directory Already Exisits"),dir.create(out_dir,recursive = T))
    write.table(out_filt,outfile,quote = F,sep = "\t",row.names = F,col.names = T)
}