source("code/assign_rbh_go.r")


#assign_rbh_go( "blast_out/maize_v3_vs_uniprot.rbh.txt","arab/ATH_GO_GOSLIM-12-16-2014.txt","datasets/blast/mz_tair10_go.txt","datasets/blast/mz_tair10_go.cafa.txt")
#rbh_file <- "blast_out/maize_v3_vs_tair10.rbh.txt"
#gaf_file <- "arab/ATH_GO_GOSLIM-12-16-2014.txt"
#out_file <- "datasets/blast/mz_tair10_go.txt"
#out_cafa <- "datasets/blast/mz_tair10_go.cafa.txt"

#assign_tair_go("blast_out/maize_v3_vs_tair10.rbh.txt","arab/ATH_GO_GOSLIM-12-16-2014.txt","rbh/tair/maize_tair.go.txt","rbh/tair/maize_v3.cafa.txt")
#assign_gaf_go("blast_out/maize_v3_vs_uniprot.rbh.txt","uniprot/annot/uniprot_hc_plant.gaf","rbh/all_plants/maize_v3.all_plants.go.txt","rbh/all_plants/maize_v3.cafa.txt")
tair_gaf = "arab/tmp.txt"
tair_gaf = "arab/ATH_GO_GOSLIM.txt"
assign_tair_go("blast_out/maize_v3_vs_tair10.rbh.txt",tair_gaf,"rbh/tair/maize_v3.tair.hc.go.txt","rbh/tair/maize_v3.hc.cafa.txt",hc=T)
assign_tair_go("blast_out/maize_v3_vs_tair10.rbh.txt",tair_gaf,"rbh/tair/maize_v3.tair.all.go.txt","rbh/tair/maize_v3.all.cafa.txt",hc=F)
