if(require("data.table")){
    library("data.table")
}else{
    install.packages("data.table")
    library("data.table")
}
#source("https://bioconductor.org/biocLite.R")
#biocLite("GO.db")
#biocLite("topGO")
library("GO.db")
#install.packages("GO.db")

source("code/plot_categories.r")
if(T){
    goancestor <- list(
        MF=as.list(GOMFANCESTOR),
        BP=as.list(GOBPANCESTOR),
        CC=as.list(GOCCANCESTOR)
    )
}

main_go_terms <- c("GO:0008150","GO:0003674","GO:0005575","GO:0005515")

go_pred_perform <- function(pred_file,test_file,gene_perf_out){
    
    #Read the predictions
    pred_data <- read.table(pred_file,header = T,sep="\t")
    print(tail(pred_data))
    
    #select the first two columns
    if(dim(pred_data)[1]>2){
        pred_data <- pred_data[,1:2]
    }
    colnames(pred_data) <- c("gene_id","go_term")
    
    #read the test dataset
    test_data <- read.table(test_file,header = F,sep="\t")
    colnames(test_data) <- c("gene_id","go_term")
    test_data <- cbind(test_data,ont=Ontology(as.character(test_data$go_term)))
    test_data <- test_data[!is.na(test_data$ont),]
    
    #filter the predictions to the genes in the test dataset
    pred_filt <- pred_data[as.character(pred_data$gene_id) %in% as.character(test_data$gene_id),]
    pred_filt <- cbind(pred_filt,ont=Ontology(as.character(pred_filt$go_term)))
    pred_filt <- pred_filt[!is.na(pred_filt$ont),]
    
    #tpos <- calc_tpos(pred_filt,test_data)
    
        mf_perf <- calc_perf(pred_filt,test_data,"MF",gene_perf_out)
        if(!is.null(mf_perf))
            mf_perf <- cbind(mf_perf,"MF")
    
        bp_perf <- calc_perf(pred_filt,test_data,"BP",gene_perf_out)
        if(!is.null(bp_perf))
            bp_perf <- cbind(bp_perf,"BP")
    
        cc_perf <- calc_perf(pred_filt,test_data,"CC",gene_perf_out)
        if(!is.null(cc_perf))
            cc_perf <- cbind(cc_perf,"CC")
        all_prf <- rbind(mf_perf,bp_perf,cc_perf)
        return(all_prf)
    
    if(F){
        ont="MF"
        pred=pred_filt
        test=test_data
    }
}


calc_perf <- function(pred,test,ont,gene_perf_out){
    pred_ont = data.table(pred[pred$ont==ont,])
    setkey(pred_ont,gene_id)
    pred_genes <- as.character(pred_ont$gene_id)
    
    test_ont = data.table(test[test$ont==ont,])
    setkey(test_ont,gene_id)
    test_genes <- as.character(test_ont$gene_id)
    
    if(length(pred_genes)==0){
        print("No annotations for the ontology")
        return(NULL)
    }
    
    uniq_genes <- unique(pred_genes[pred_genes %in% test_genes])
    #uniq_genes <- as.character(unique(pred_ont$gene_id))
    #as.character(unique(test_ont$gene_id))
    
    tmp <- lapply(uniq_genes,function(x){
        #print(x)
        gene <- x
        tmp_pred <- pred_ont[gene]
        pred_terms <- as.character(tmp_pred$go_term)
        tmp_test <- test_ont[gene]
        test_terms <- as.character(tmp_test$go_term)
        
        all_pred_terms <- unique(unlist(lapply(pred_terms,get_go_ancestor)))
        all_pred_terms <- all_pred_terms[-1] 
        all_pred_terms <- all_pred_terms[!main_go_terms %in% all_pred_terms]
        
        all_test_terms <- unique(unlist(lapply(test_terms,get_go_ancestor)))
        all_test_terms <- all_test_terms[-1]
        all_test_terms <- all_test_terms[!main_go_terms %in% all_test_terms]
        
        tp <- intersect(all_pred_terms,all_test_terms)
        fp <- setdiff(all_pred_terms,all_test_terms)
        fn <- setdiff(all_test_terms,all_pred_terms)
        
#         tps_direct <- intersect(test_terms,pred_terms)
#         pred_ancest <- lapply(pred_terms,ancestor_match,test_go_ids=tmp_test$go_term)
#         pred_ancest <- do.call(rbind,pred_ancest)
#         fp <- setdiff(pred_terms, c(tps_direct,pred_ancest[,1]))
#         print(fp)
#         tps_offspring <- intersect(as.character(tmp_test$go_term),unlist(pred_ancest[,2]))
#         tps_all <- union(tps_direct,tps_offspring)
#         print(tps_all)
        num_preds <- length(tmp_pred$go_term)
        num_test  <- length(tmp_test$go_term)
        num_tp    <- length(tp)
        num_fn    <- length(fn)
        num_fp    <- length(fp)
        c(gene,num_preds,num_test,num_tp,num_fp,num_fn)
    })
    perf_results <- do.call(rbind,tmp)
    colnames(perf_results) <- c("gene","num_preds","num_test","num_tp","num_fp","num_fn")
    perf_results[,2:6] <- apply(perf_results[,2:6],2,as.numeric)
    out_file <- paste(gene_perf_out,"_",ont,".out",sep="")
    out_dir <- dirname(out_file)
    #print(out_file)
    ifelse(!dir.exists(out_dir),dir.create(out_dir),print(paste(out_dir,"already exists so not creating one")))
    write.table(perf_results,out_file,quote = F,sep = "\t",row.names = F)
    return(perf_results)
}

ancestor_match <- function(go_id,test_go_ids){
    go_id <- as.character(go_id)
    pred_ancest <- get_go_ancestor(go_id)
    
    match_terms <- intersect(as.character(test_go_ids),pred_ancest)
    if(length(match_terms)>0){
        c(go_id,list(match_terms))    
    }else{
        NULL
    }
}

get_go_ancestor <- function(go_id){
    go_id <- as.character(go_id)
    ont <- unlist(Ontology(go_id))
    if(length(ont)>0)
        ancestors <- rev(unlist(goancestor[[ont]][[go_id]]))
    else
        ancestors <- NULL
    return(ancestors)
}