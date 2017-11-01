# library("data.table")
# library("ggplot2")
# library("reshape2")
# library("tools")
# library("GOSemSim")
# library("parallel")
# 
# 
# source("code/obo_tools.r")
# source("code/gen_utils.r")
# source("code/gaf_tools.r")
# source("code/get_cons.r")
# source("code/get_nr_dataset.r")
# source("code/pos_score.r")
source("code/eval_tools.r")


go_file="obo/go.obo"
gold_file="nr_data/maize_v3.gold.gaf"

#check and read/load the go.obo file
go_obo = check_obo_data(go_file)

#read the gold standard file
gold = read_gaf(gold_file)
setkey(gold,db_object_symbol)
gold = gold[grep("GRMZM|AC",db_object_symbol)]
#this line is to remove duplicate annotations with different evidence codes
gold = gold[,.SD[1],by=list(db_object_symbol,term_accession)]
setkey(gold,db_object_symbol)

datasets = fread("datasets.txt")
comb_datasets = fread("comb_datasets.txt")
exist_datasets = fread("exist_datasets.txt")
all_datasets = rbind(datasets,comb_datasets,exist_datasets)

tmp_list = apply(all_datasets,1,function(x){
    infile=paste("nr_data/",x["file"],sep="")
    print(infile)
    eval_nr(infile,gold,go_obo)
})