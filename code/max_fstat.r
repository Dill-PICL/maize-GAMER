
calc_fstat <- function(infile,outdir,scores){
    ifelse(dir.exists(outdir),print("Ouput Directory Exisits"),dir.create(outdir))
    
    in_data <- read.table(infile,header = T,sep = "\t")
    colnames(in_data) <- c("gene","go_id","score")
    hist(in_data$score)
    
    #pred_file,test_file,gene_perf_out
    test_file <- "test_datasets/maizegdb/annot/maizegdb_annot.txt"
    tool_name <- gsub(".*/","",dirname(infile))[[1]]
    pred_file <- paste("tmp/",tool_name,".txt",sep = "")
    
    tmp_fstat <- lapply(scores,function(x){
        if(T){
            filt_data <- in_data[in_data$score>=x,]
            if(dim(filt_data)[1]>0){
                write.table(filt_data,pred_file,quote = F,sep = "\t",row.names = F,col.names = T)
                out_file <- paste(outdir,"/",x,sep = "")
                
                all_perf <- go_pred_perform(pred_file,test_file,out_file)
                if(!is.null(all_perf)){
                    all_perf <- data.frame(all_perf)
                    colnames(all_perf)[7] <- "GO"
                    all_perf[,2:6] = as.data.frame(lapply(all_perf[,2:6],function(x){as.numeric(as.character(x))}))
                    all_perf_dt <- data.table(all_perf)
                    
                    pr_rc <- all_perf_dt[,list(pr=calc_pr(num_tp,num_fp),rc=calc_rc(num_tp,num_fn)),by=GO]
                    fstat <- (2*pr_rc$pr*pr_rc$rc)/(pr_rc$pr+pr_rc$rc)
                    pr_rc <- cbind(pr_rc,fstat,th=x)
                    pr_rc
                }else{
                    NULL
                }
            }else{
                NULL
            }
        }
    })
    
    tmp_fstat
    fstats <- do.call(rbind,tmp_fstat)
    barplot(fstats[fstats$GO=="MF"]$fstat,ylim = c(0,1),names.arg = fstats[fstats$GO=="MF"]$th)
    barplot(fstats[fstats$GO=="BP"]$fstat,ylim = c(0,1),names.arg = fstats[fstats$GO=="BP"]$th)
    barplot(fstats[fstats$GO=="CC"]$fstat,ylim = c(0,1),names.arg = fstats[fstats$GO=="CC"]$th)
    
    dim(in_data[in_data$score>=0.5,])
    onts <- Ontology(as.character(in_data$go_id))
    in_data_ont <- cbind(in_data,onts)
    in_data_ont <- in_data_ont[!is.na(onts),]
    
    head(in_data_ont)
    
    plot(fstats[fstats$GO=="MF"]$rc,fstats[fstats$GO=="MF"]$pr,type="l",xlim=c(0,1),ylim=c(0,1),xlab="Precision",ylab="Recall")
    
}

calc_pr <- function(num_tp,num_fp){
    pr <- mean(num_tp/(num_tp+num_fp))
    return(pr)
}

calc_rc <- function(num_tp,num_fn){
    rc <- mean(num_tp/(num_tp+num_fn))
    return(rc)
}