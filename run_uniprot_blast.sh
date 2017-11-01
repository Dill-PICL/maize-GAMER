outfmt="6 qseqid sseqid qlen qstart qend slen sstart send evalue bitscore score length pident nident gaps"

uniprot_fa="uniprot/fa/uniprot_hc_plant.fa"
uniprot_db="blastdb/uniprot.hc"
maize_fa="maize_v3/maize_v3.longest.aa.fa"
maize_db="blastdb/maize_v3"

#qmicro "makeblastdb -in $uniprot_fa -dbtype prot -out $uniprot_db" "uniprot_db"
#qmicro "makeblastdb -in $maize_fa   -dbtype prot -out $maize_db" "maize_db"

blastp -db $maize_db -query $uniprot_fa -max_target_seqs 10 -out blast_out/uniprot2maizedb.txt -outfmt "$outfmt" -num_threads 16
blastp -db $uniprot_db -query $maize_fa -max_target_seqs 10 -out blast_out/maize2uniprotdb.txt -outfmt "$outfmt" -num_threads 16
