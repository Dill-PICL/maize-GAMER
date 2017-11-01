source("../code/get-rbh.r")
source("../code/rbh-go.r")
source("../compile_datasets/code/gaf_tools.r")

blast_cols = fread("../blast_cols.txt",header = F)$V1

all_datasets = fread("annot/annot_count_spp.csv")

out = apply(all_datasets[1:10],1,function(x){
    mz2db_f = paste("blast_out/maize-vs-",trimws(x["V2"]),".out",sep = "")
    db2mz_f = paste("blast_out/",trimws(x["V2"]),"-vs-maize.out",sep = "")
    rbh_file = paste("rbh/maize-vs-",trimws(x["V2"]),".rbh.txt",sep="")
    get_rbh(db2mz_f,mz2db_f,10e-6,rbh_file,blast_cols)
    print(rbh_file)
})


gaf_cols = fread("../gaf_cols.txt",header = F)$V1
uniprot_gaf = fread("annot/uniprot_hc_plant.gaf",sep = "\t",skip = 5)
uniprot_gaf$V16 = as.character(uniprot_gaf$V16)
uniprot_gaf$V16 = ""
colnames(uniprot_gaf) = gaf_cols
setkey(uniprot_gaf,db_object_id)

x = unlist(all_datasets[1])
out = apply(all_datasets[1:10],1,function(x){
    #x["V2"]
    rbh_file = paste("rbh/maize-vs-",trimws(x["V2"]),".rbh.txt",sep="")
    rbh_data = fread(rbh_file,sep = "\t",header = F,stringsAsFactors = F)
    colnames(rbh_data) = c("maize","other") 
    
    rbh_data$maize = gsub("_P[0-9]+","",rbh_data$maize)
    rbh_data$maize = gsub("FGP","FG",rbh_data$maize)
    
    rbh_data$other = tstrsplit(rbh_data$other,"\\|",keep=c(2))
    
    tmp_rbh = merge(rbh_data,uniprot_gaf,by.x="other",by.y="db_object_id")
    tmp_rbh = data.table(tmp_rbh)
    colnames(tmp_rbh)[1] = "db_object_id"
    tmp_rbh$evidence_code = "IEA"
    tmp_rbh$db_object_id = tmp_rbh$maize
    tmp_rbh$db_object_symbol = tmp_rbh$maize
    tmp_rbh$db_reference = "MG:0000"
    tmp_rbh$db_object_name = tmp_rbh$maize
    tmp_rbh$db_object_synonym = tmp_rbh$maize
    tmp_rbh$taxon = "taxon:4577"
    tmp_rbh$date = as.character(tmp_rbh$date)
    tmp_rbh$date  = format(Sys.time(),"%Y%m%d")
    tmp_rbh$assigned_by = "UniProt"
    rbh_gaf = tmp_rbh[,-c("maize"),with=F]
    rbh_gaf = data.table(rbh_gaf)
    rbh_gaf$with = ""
    rbh_gaf$db = "maize-GAMER"
    rbh_gaf[,annotation_extension:=""]
    rbh_gaf[,db_object_type:="gene"]
    rbh_gaf[,gene_product_form_id:=""]
    setcolorder(rbh_gaf,gaf_cols)
})

all_out = do.call(rbind,out)
all_out[,list(count=.N),by=list(db_object_id,term_accession)][count>1]
all_out

write_gaf(all_out,"gaf/maize_v3.uniprot_plants.gaf")