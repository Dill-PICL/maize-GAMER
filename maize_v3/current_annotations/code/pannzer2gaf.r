pannzer2gaf <- function(in_file,out_gaf){
    print("Reading the input file")
    in_file="PANNZER/results/pannzer_go.txt"
    out_file="PANNZER/gaf/pannzer-0.0.gaf"
    gaf_date = format(Sys.time(),"%m%d%Y")
    
    
    
    pannzer_data = fread(in_file)
    tmp = gsub("_P[0-9]+","",pannzer_data$QueryId)
    tmp = gsub("FGP","FG",tmp,fixed = T)
    tmp
    
    gaf_cols=fread("../gaf_cols.txt",header = F)$V1
    gaf_cols
    pannzer_data
    print("Converting to GAF 2.0")
    gaf_data = pannzer_data[,.(QueryId,GO_class,Score)]
    colnames(gaf_data) = c("db_object_id","term_accession","with")
    
    min_score=min(gaf_data$with)
    max_score=max(gaf_data$with)
    gaf_data$with = (gaf_data$with - min_score)/(max_score - min_score)
    
    obo_data = check_obo_data("go.obo")
    
    tmp_aspect = get_aspect(obo_data,gaf_data$term_accession)
    gaf_data[,aspect:=tmp_aspect]
    
    
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
    gaf_data[,date:=gaf_date]
    gaf_data[,assigned_by:="PANNZER"]
    gaf_data[,annotation_extension:=""]
    gaf_data[,gene_product_form_id:=""]
    setcolorder(gaf_data,gaf_cols)
    
    print("Writing the outfile")
    write_gaf(gaf_data,out_gaf)
}