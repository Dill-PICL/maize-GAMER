source("code/gaf_tools.r")

datasets = fread("datasets.txt")
exist_datasets = fread("exist_datasets.txt")

proc_datasets = rbind(datasets,exist_datasets)

all_red = apply(proc_datasets,1, function(x){
    infile = paste("raw_data/",x["file"],sep="")
    dt_name = x["dataset"]
    names(dt_name) = NULL
    out_name = paste("uniq_data/",x["file"],sep="")
    print(dt_name)
    data = read_gaf(infile)
    print(data)
    gaf_cols = colnames(data)
    non_dup_len = NROW(data[,list(count=.N),by=list(db_object_id,term_accession)])
    dup_len = NROW(data)
    print(dup_len)
    cat(dup_len,non_dup_len,"\n")
    dup_perc = (dup_len-non_dup_len)/dup_len*100
    uniq_data = data[,.SD[1],by=c("db_object_id","term_accession")]  
    setcolorder(uniq_data,gaf_cols)
    write_gaf(uniq_data,out_name)
    print(c(dt_name=dt_name,raw_num=NROW(data),uniq_num=NROW(uniq_data),dup_perc=dup_perc))
})

dup_tbl = data.table(t(all_red))
dup_tbl$dup_perc = as.numeric(dup_tbl$dup_perc)
write.table(dup_tbl,file = "tables/dt_dups.csv",sep = "\t",row.names = F)


