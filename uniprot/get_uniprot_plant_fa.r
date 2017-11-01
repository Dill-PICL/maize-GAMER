library("data.table")
library("ggplot2")
library("jsonlite")

data = fread("annot/taxon.txt",skip = 6)
unique_ids = unique(data$V2)

ids_txt = paste(unique_ids,collapse = ",")
    json.url = sprintf("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=taxonomy&id=%s&retmode=json&ret_max=500",ids_txt)
    tax_summary = fromJSON(json.url,simplifyVector = F)
    
sci_names = lapply(unique_ids,function(id){
    print(tax_summary$result[[as.character(id)]]$scientificname)
})

id_name_tbl = data.table(cbind(id=unique_ids,sci_name=unlist(sci_names)))

id_name_tbl
data$V2 = as.character(data$V2)
sci_name_data = merge(data,id_name_tbl,by.x = "V2",by.y = "id")


sci_name_count = sci_name_data[,list(count=.N),by=list(sci_name,V2)]


top_10_spp = sci_name_count[order(count,decreasing = T)][1:10]


sci_name_count[grep("Zea",sci_name)]

write.table(sci_name_count[order(count,decreasing = T)][count>100],file = "annot_count_spp.csv",sep = "\t",quote = F,row.names = F)


sci_name_data[!V2 %in% top_10_spp$V2]

top10_oufiles = lapply(top_10_spp$V2,function(id){
#id = top_10_spp$V2[1]
    uniprot_url = sprintf("http://www.ebi.ac.uk/QuickGO-Old/GAnnotation?format=fasta&limit=-1&tax=%s",id)
    uniprot_url
    #outfile = sprintf("fa/plants/%s.fa",id)
    download.file(uniprot_url,destfile = outfile)
    outfile
})