library("data.table")

if(F){
    db2mz     <- "ara-mz-aa.txt"
    mz2db     <- "mz-ara-aa.txt"
    evalue_th  <- 10e-10
    rbh_out    <- "maize_v3_vs_tair10.rbh.txt"
}

get_rbh <- function(db2mz,mz2db, evalue_th,rbh_out,blast_cols){
    db2mz_blast <- fread(db2mz,header = F,sep = "\t",stringsAsFactors = F)
    colnames(db2mz_blast) <- blast_cols
    #db2mz_blast <- data.table(db2mz_blast)
    setkeyv(db2mz_blast,c("qseqid","sseqid"))
    db2mz_blast <- db2mz_blast[evalue < evalue_th]
    which_min_eval <- db2mz_blast[,list(min_ind=.I[which.min(evalue)]),by=qseqid]
    db2mz_blast_filt <- db2mz_blast[which_min_eval$min_ind]
    #db2mz_blast_filt
    db2mz_hits <- paste(db2mz_blast_filt$qseqid,db2mz_blast_filt$sseqid,sep = "-")
    
    mz2db_blast <- fread(mz2db,header = F,sep = "\t",stringsAsFactors = F)
    colnames(mz2db_blast) <- blast_cols
    #mz2db_blast <- data.table(mz2db_blast)
    setkeyv(db2mz_blast,c("qseqid","sseqid"))
    mz2db_blast <- mz2db_blast[evalue < evalue_th]
    which_min_eval <- mz2db_blast[,list(min_ind=.I[which.min(evalue)]),by=qseqid]
    mz2db_blast_filt <- mz2db_blast[which_min_eval$min_ind]
    #mz2db_blast_filt
    mz2db_hits <- paste(mz2db_blast_filt$sseqid,mz2db_blast_filt$qseqid,sep="-")
    #head(mz2db_hits)
    
    rbh <- mz2db_blast_filt[mz2db_hits %in% db2mz_hits]
    write.table(rbh[,1:2,with=F],file = rbh_out,sep = "\t",quote = F,row.names = F,col.names = F)
}