source("../compile_datasets/code/gaf_tools.r")
library("data.table")

tair_data = fread("ATH_GO_GOSLIM.txt")
tair_cols = fread("arab_ath_cols.txt",header = F)$V1
colnames(tair_data) = tair_cols

gaf_cols=fread("../gaf_cols.txt",header = F)$V1
gaf_cols

arab_gaf = tair_data[grep("^AT.G",object_name),.(locus_name,go_id,aspect,ev_code,ev_with,reference,assigned_by,date)]
arab_gaf$locus_name = substr(arab_gaf$locus_name,1,9)
arab_gaf = cbind(arab_gaf,db="TAIR")
arab_gaf = cbind(arab_gaf,db_object_id=arab_gaf$locus_name,db_object_symbol=arab_gaf$locus_name)
arab_gaf = cbind(arab_gaf,db_object_name="",db_object_synonym="",db_object_type="protein",taxon="taxon:4577")
colnames(arab_gaf)[grep("ev_with",colnames(arab_gaf))] = "with"
colnames(arab_gaf)[grep("reference",colnames(arab_gaf))] = "db_reference"
colnames(arab_gaf)[grep("go_id",colnames(arab_gaf))] = "term_accession"
colnames(arab_gaf)[grep("ev_code",colnames(arab_gaf))] = "evidence_code"
arab_gaf = cbind(arab_gaf,annotation_extension="",gene_product_form_id="",qualifier="")

colnames(arab_gaf)[!colnames(arab_gaf) %in% gaf_cols]
gaf_cols[!gaf_cols %in% colnames(arab_gaf)]
arab_gaf = arab_gaf[,-c("locus_name"),with=F]

setcolorder(arab_gaf,gaf_cols)

write_gaf(arab_gaf,"gaf/TAIR10.gaf")