library("data.table")
library("ggplot2")
library("reshape2")
library("tools")

read_gaf = function(infile){
    gaf_cols = c("db",
                 "db_object_id",
                 "db_object_symbol",
                 "qualifier",
                 "term_accession",
                 "db_reference",
                 "evidence_code",
                 "with",
                 "aspect",
                 "db_object_name",
                 "db_object_synonym",
                 "db_object_type",
                 "taxon",
                 "date",
                 "assigned_by",
                 "annotation_extension",
                 "gene_product_form_id")
    
    if(!file.exists(infile)){
        warning("The file does not exist")
        break
    }
    in_lines = readLines(infile,n=25)
    comments = grep("^!",in_lines)
    if(length(comments)==0){
        comments=0    
    }
    
    curr_gaf = fread(infile,skip = max(comments))
    colnames(curr_gaf) = gaf_cols
    curr_gaf[is.na(curr_gaf)] = ""
    return(curr_gaf)
}

read_gaf_header = function(infile){
    if(!file.exists(infile)){
        warning("The file does not exist")
        break
    }
    curr_gaf = fread(infile,skip = 1,nrows = 25)
    colnames(curr_gaf) = gsub("!","",colnames(curr_gaf))
    return(colnames(curr_gaf))
}

write_gaf = function(out_gaf,outfile){
    cat(outfile,"\n")
    colnames(out_gaf)[1] <- paste("!",colnames(out_gaf)[1],sep="")
    out_gaf[is.na(out_gaf)] = ""
    
    cat("!gaf-version:2.0\n",file = outfile)
    cat(paste(colnames(out_gaf),collapse = "\t"),file = outfile,append = T)
    cat("\n",file = outfile,append = T)
    write.table(out_gaf,outfile,quote = F,sep = "\t",append = T,row.names = F,col.names = F)
}

read_all_nr <- function(all_datasets){
    
    #Get all the file names from the directory
    #all_datasets = dir(data_dir,pattern = ".gaf",full.names = T)
    #all_datasets
    
    #filter things that are not part of the pipeline
    datasets = grep("gramene49|phytozome|test.gaf",all_datasets,value = T,invert = T)
    
    #filter things that are not part of the pipeline
    gaf_header = read_gaf_header(datasets[1])
    
    #read the datasets 
    tmp_gafs <- lapply(datasets,function(x){
        print(paste("Processing",x))
        tmp_gaf = read_gaf(x)
        colnames(tmp_gaf) = gaf_header
        print(dim(tmp_gaf))
        tmp_gaf
    })
    
    #combine all the datasets and remove NAs which were included by coercion
    all_datasets = do.call(rbind,tmp_gafs)
    all_datasets[is.na(all_datasets)] = ""
    
    #change the column names from a poperly formatted dataset
    colnames(all_datasets) = gaf_header
    
    #return the datasets
    return(all_datasets)
}

gaf_check_simple = function(go_obo,tmp_gaf){
    cat("Checking gaf file for simple errors and fixing them\n")
    namespace2aspect=list("molecular_function"="F","biological_process"="P","cellular_component"="C")
    alt_idxs = tmp_gaf[,.I[tmp_gaf$term_accession %in% names(go_obo$alt_conv)],]
    
    out_gaf = tmp_gaf
    
    if(length(alt_idxs)>0){
        out_gaf$term_accession[alt_idxs]
        go_obo$alt_conv[out_gaf$term_accession[alt_idxs]]
        out_gaf$term_accession[alt_idxs] = unlist(go_obo$alt_conv[out_gaf$term_accession[alt_idxs]])
        
        namespace2aspect=list("molecular_function"="F","biological_process"="P","cellular_component"="C")
        
        length(go_obo$namespace[out_gaf$term_accession])
        tmp_aspect = unlist(namespace2aspect[unlist(go_obo$namespace[out_gaf$term_accession])])
        old_aspect = tmp_gaf$aspect
        out_gaf$aspect = tmp_aspect
    }
    
    out_gaf$evidence_code[out_gaf$evidence_code==""] = "IEA"
    
    return(out_gaf)
}
