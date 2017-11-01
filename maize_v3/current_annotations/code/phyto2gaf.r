phyto2gaf = function(in_file,out_gaf){
    phyto_data = fread(in_file)
    phyto_filt = phyto_data[GO!="",.(locusName,GO)]
    
    tmp_list = apply(phyto_filt,1,function(x){
        GOs = unlist(strsplit(x["GO"],","))
        tmp_out = cbind(gene=x["locusName"],GO=GOs)
        tmp_out
    })
    gaf_data = data.table(do.call(rbind,tmp_list))
    colnames(gaf_data) = c("db_object_id","term_accession")
    gaf_data = gaf_data[db_object_id %in% refset]
    gaf_data[,term_accession:=substr(term_accession,4,13)]
    gaf_data[,db:="Phytozome"]
    gaf_data[,db_object_symbol:=db_object_id]
    #gaf_data[,qualifier:=""]
    gaf_data[,db_reference:="MG:0000"]
    gaf_data[,evidence_code:="IEA"]
    #gaf_data[,with:=""]
    
    
    tmp_aspect = get_aspect(obo_data,gaf_data$term_accession)
    gaf_data[,aspect:=tmp_aspect]
    
    #gaf_data[,db_object_name:=""]
    #gaf_data[,db_object_synonym:=""]
    gaf_data[,db_object_type:="gene"]
    gaf_data[,taxon:="taxon:4577"]
    gaf_data[,date:=gaf_date]
    gaf_data[,assigned_by:="Phytozome"]
    
    unset_cols = gaf_cols[!gaf_cols %in% names(gaf_data)]
    lapply(unset_cols,function(x){
        gaf_data <<- cbind(gaf_data,x="")
        colnames(gaf_data)[length(gaf_data)] <<- x
        
    })
    setcolorder(gaf_data,gaf_cols)
    write_gaf(gaf_data,out_gaf)
}