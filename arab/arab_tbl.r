source("../compile_datasets/code/gaf_tools.r")
library("data.table")

arab_gaf = read_gaf("gaf/TAIR10.gaf")
non_hc_ev = c("IEA","ND","NAS")
ont_counts = merge(arab_gaf[,list(all=.N),by=(aspect)], arab_gaf[!evidence_code %in% non_hc_ev,list(hc=.N),by=(aspect)])
write.table(ont_counts,"tables/ont_counts.csv",sep = "\t",row.names = F,quote = F)

arab_gaf

ev_desc = fread("../ev_desc.txt",stringsAsFactors = T)
type_order = c("Experimental","Computational","Curator","Author","Automatic")

ev_desc$type = factor(ev_desc$type, levels=type_order)
ev_code_count = merge(ev_desc,arab_gaf[,list(annot_count=.N,gene_count=length(unique(db_object_id))),by=(evidence_code)],by.x = "ev_code",by.y = "evidence_code")

ev_code_count$type = factor(ev_code_count$type,levels = type_order)
ev_code_count = ev_code_count[order(annot_count,decreasing = T)][order(type)]

write.table(ev_code_count,"tables/ev-code-counts.csv",sep = "\t",row.names = F,quote = F)

length(unique(arab_gaf[!evidence_code %in% non_hc_ev]$db_object_id))
