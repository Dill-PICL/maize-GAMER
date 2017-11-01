gramene2gaf = function(in_file,out_gaf){
    in_data = read_gaf(in_file)
    in_data
    
    gaf_data = data.table(in_data)
    
    gaf_data = gaf_data[db_object_id %in% refset]
    gaf_data[,db_object_symbol:=db_object_id]
    gaf_data[,taxon:=paste("taxon:",taxon,sep="")]
    
    tmp_aspect = get_aspect(obo_data,gaf_data$term_accession)
    gaf_data[,aspect:=tmp_aspect]
    
    setcolorder(gaf_data,gaf_cols)
    write_gaf(gaf_data,out_gaf)
}