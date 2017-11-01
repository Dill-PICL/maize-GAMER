library("reshape2")

source("code/gaf_tools.r")
source("code/obo_tools.r")
source("code/argot2gaf.r")
source("code/pannzer2gaf.r")
source("code/fanngo2gaf.r")

argot2_res="argot2/results/argot2.0.tsv"
argot2_gaf="argot2/gaf/argot2-0.0.gaf"
filter_argot2(in_file=argot2_res,out_file=argot2_gaf)

pannzer_res = "PANNZER/results/pannzer_go.txt"
pannzer_gaf = "PANNZER/gaf/pannzer-0.0.gaf"
pannzer2gaf(in_file = pannzer_res,out_gaf=pannzer_gaf)

fanngo_res="FANNGO_linux_x64/scores.txt"
fanngo_gaf="FANNGO_linux_x64/gaf/fanngo-0.0.gaf"
fanngo2gaf(in_file=fanngo_res,out_gaf=fanngo_gaf)

if(F){
    argot2_data = fread("argot2/results/argot2.0.tssv")
    tmp = gsub("_P[0-9]+","",argot2_data$Sequence)
    tmp = gsub("FGP","FG",tmp,fixed = T)
    tmp
    
    gaf_cols=fread("../gaf_cols.txt",header = F)$V1
    gaf_cols
    
    gaf_data = argot2_data[,.(Sequence,`GO ID`,`Total Score`,Aspect)]
    colnames(gaf_data) = c("db_object_id","term_accession","with","aspect")
    
    gaf_data[,db_object_id:=tmp]
    gaf_data[,db_object_symbol:=tmp]
    gaf_data[,db:="maize-GAMER"]
    gaf_data[,qualifier:=0]
    gaf_data[,db_reference:="MG:0000"]
    gaf_data[,evidence_code:="IEA"]
    gaf_data[,db_object_name:=""]
    gaf_data[,db_object_synonym:=""]
    gaf_data[,db_object_type:="protein"]
    gaf_data[,taxon:="taxon:4577"]
    gaf_data[,date:="03272017"]
    gaf_data[,assigned_by:="Argot2"]
    gaf_data[,annotation_extension:=""]
    gaf_data[,gene_product_form_id:=""]
    
    setcolorder(gaf_data,gaf_cols)
    
    write_gaf(gaf_data,"argot2/gaf/argot2-0.0.gaf")
}
