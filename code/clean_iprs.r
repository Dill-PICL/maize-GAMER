library("data.table")
library("GO.db")

clean_iprs<- function(infile,outfile){
    out_dir <- dirname(outfile)
    ifelse(!dir.exists(out_dir),dir.create(out_dir),warning(paste("Directory ",out_dir," exists")))
    
    iprs_data <- read_iprs_go(infile)
    setkeyv(iprs_data,c("gene","go_id"))
    
    clean_out <- paste(outfile,".clean.txt",sep = "")
    write.table(iprs_data,clean_out,quote = F,sep = "\t",row.names = F)
    
    iprs_data_filt <- unique(iprs_data)
    onts <- Ontology(iprs_data_filt$go_id)
    iprs_cafa_out <- cbind(iprs_data_filt$gene,iprs_data_filt$go_id,onts)
    cafa_out <- paste(outfile,".cafa.txt",sep = "")
    colnames(iprs_cafa_out) <- c("gene_id","go_term","aspect")
    write.table(iprs_cafa_out,cafa_out,quote = F,sep = "\t",row.names = F)
}

read_iprs_go <- function(infile){
    con <- file(infile,blocking = F)
    in_data <- readLines(con)
    close(con)
    
    tmp <- lapply(in_data,function(x){
        is_go <- grep("GO:",x,fixed = T)
        if(length(is_go)>0){
            cols <- unlist(strsplit(x,"\t"))
            gene      <- cols[1]
            src_db    <- cols[4]
            src_db_id <- cols[5]
            ipr_id    <- cols[12]
            evalue    <- cols[9]
            go_ids    <- unlist(strsplit(cols[14],"|",fixed = T))
            out <- cbind(gene,src_db,src_db_id,evalue,ipr_id,go_ids)
            out
        }
    })
    out <- do.call(rbind,tmp)
    colnames(out) <- c("gene","src_db","src_db_id","evalue","ipr_id","go_id")
    out <- data.table(out)
    return(out)
}
