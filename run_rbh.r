source("code/get-rbh.r")

get_rbh("blast_out/ara-mz-aa.txt","blast_out/mz-ara-aa.txt",10e-10,"blast_out/maize_v3_vs_tair10.rbh.txt")
get_rbh("blast_out/uniprot2maizedb.txt","blast_out/maize2uniprotdb.txt",10e-10,"blast_out/maize_v3_vs_uniprot.rbh.txt")