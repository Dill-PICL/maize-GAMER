filter_argot2 <- function(in_file,out_file){
    print("Reading the input file")
    argot2_data = fread(in_file)
    tmp = gsub("_P[0-9]+","",argot2_data$Sequence)
    tmp = gsub("FGP","FG",tmp,fixed = T)
    tmp
    
    gaf_cols=fread("../gaf_cols.txt",header = F)$V1
    gaf_cols
    
    print("Converting to GAF 2.0")
    gaf_data = argot2_data[,.(Sequence,`GO ID`,`Internal Confidence`,Aspect)]
    colnames(gaf_data) = c("db_object_id","term_accession","with","aspect")
    
    gaf_data$with = as.numeric(gaf_data$with)
    min_score=min(gaf_data$with)
    max_score=max(gaf_data$with)
    gaf_data$with = (gaf_data$with - min_score)/(max_score - min_score)
    
    gaf_data[,db_object_id:=tmp]
    gaf_data[,db_object_symbol:=tmp]
    gaf_data[,db:="maize-GAMER"]
    gaf_data[,qualifier:=0]
    gaf_data[,db_reference:="MG:0000"]
    gaf_data[,evidence_code:="IEA"]
    gaf_data[,db_object_name:=""]
    gaf_data[,db_object_synonym:=""]
    gaf_data[,db_object_type:="gene"]
    gaf_data[,taxon:="taxon:4577"]
    gaf_data[,date:="03272017"]
    gaf_data[,assigned_by:="Argot2"]
    gaf_data[,annotation_extension:=""]
    gaf_data[,gene_product_form_id:=""]
    setcolorder(gaf_data,gaf_cols)
    
    print("Writing the outfile")
    write_gaf(gaf_data,out_file)
}