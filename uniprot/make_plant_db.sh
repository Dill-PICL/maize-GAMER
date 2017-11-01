outfmt="6 qseqid sseqid qlen qstart qend slen sstart send evalue bitscore score length pident nident gaps"

#qsub_create "blastp -db tair10_aa -query maize_v3/maize_v3.longest.aa.fa  -max_target_seqs 20 -out blast_out/mz-ara-aa.txt -outfmt '$outfmt' -num_threads 16" "mz-ara-aa" 1 16 8 24

function make_db {
	db_name=`basename $1 | sed 's/.fa//g'`
	echo qsub_create "
	source load_modules.sh
	makeblastdb -in $1 -dbtype 'prot' -out blastdb/$db_name" "$db_name.blstdb" 1 16 8 24
}

for f in $@
do
	make_db $f
done
