fasta_formatter -i TAIR10_pep_20110103_representative_gene_model_updated -o tair10_aa.fa
makeblastdb -in tair10_aa.fa -dbtype prot -hash_index -out /home/kokul/work_dir/blastdb/tair10_aa  -title tair10_aa
