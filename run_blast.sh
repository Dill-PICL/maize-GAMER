outfmt="6 qseqid sseqid qlen qstart qend slen sstart send evalue bitscore score length pident nident gaps"

blastp -db tair10_aa -query maize_v3/maize_v3.longest.aa.fa  -max_target_seqs 20 -out blast_out/mz-ara-aa.txt -outfmt "$outfmt" -num_threads 16
blastn -db tair10_cds -task blastn -query maize_v3/maize_v3.longest.cds.fa  -max_target_seqs 20 -out blast_out/mz-ara-cds.txt -outfmt "$outfmt" -num_threads 16
blastp -db maize_v3_aa -query arab/tair10_aa.fa  -max_target_seqs 20 -out blast_out/ara-mz-aa.txt -outfmt "$outfmt" -num_threads 16
blastn -db maize_v3_cds -task blastn -query arab/tair10_cds.fa  -max_target_seqs 20 -out blast_out/ara-mz-cds.txt -outfmt "$outfmt" -num_threads 16
