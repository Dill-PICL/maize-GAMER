outfmt="6 qseqid sseqid qlen qstart qend slen sstart send evalue bitscore score length pident nident gaps"
#qsub_create "blastp -db tair10_aa -query maize_v3/maize_v3.longest.aa.fa  -max_target_seqs 20 -out blast_out/mz-ara-aa.txt -outfmt '$outfmt' -num_threads 16" "mz-ara-aa" 1 16 8 24
#qsub_create "blastn -db tair10_cds -task blastn -query maize_v3/maize_v3.longest.cds.fa  -max_target_seqs 20 -out blast_out/mz-ara-cds.txt -outfmt '$outfmt' -num_threads 16" "mz-ara-cds" 1 16 8 24
#qsub_create "blastp -db maize_v3_aa -query arab/tair10_aa.fa  -max_target_seqs 20 -out blast_out/ara-mz-aa.txt -outfmt '$outfmt' -num_threads 16" "ara-mz-aa" 1 16 8 24
#qsub_create "blastn -db maize_v3_cds -task blastn -query arab/tair10_cds.fa  -max_target_seqs 20 -out blast_out/ara-mz-cds.txt -outfmt '$outfmt' -num_threads 16" "ara-mz-cds" 1 16 8 24
#blastp -db blastdb/uniprotdb -query maize_v3/maize_v3.longest.aa.fa -outfmt 11 -out maize_v3.asn -num_threads 3
#gpu-makeblastdb -in uniprotdb/uniprotdb -out gpudb/uniprotdb -dbtype prot  -sort_volumes -max_file_sz 500MB
#cd blastdb
#gpu-blastp -db gpudb/uniprotdb -query maize_v3/maize_v3.longest.aa.fa -outfmt 11 -out maize_v3.asn -gpu t -method 2 -gpu_threads 32 -gpu_blocks 256
#gpu-blastp -db blastdb/uniprotdb -query maize_v3/maize_v3.longest.aa.fa -outfmt 6 -out maize_v3.asn -gpu T -method 1 -gpu_threads 32 -gpu_blocks 256
#cd ..
#blastp -db blastdb/uniprotdb -query maize_v3/maize_v3.longest.aa.fa -evalue 10 -num_alignments 250 -outfmt 6 -out maize_v3.asn -num_threads 2  #-gpu t -gpu_threads 32 -gpu_blocks 256 -method 1

function blast_plant {
	query=$1
	db=$2
	plant=`basename $query | sed 's/.fa//g'`
	out_file="$plant-vs-maize"
	qsub_create "
	source load_condo.sh
	blastp -db $db -query $query -max_target_seqs 10 -out blast_out/$out_file.out -outfmt '$outfmt' -num_threads 32" "$out_file" 1 16 "compute" 4
}

function blast_maize {
	db=`basename $1 | sed 's/.fa//g'`
	db="blastdb/$db"
	query=$2
	plant=`basename $db`
	out_file="maize-vs-$plant"
	qsub_create "
	source load_condo.sh
	blastp -db $db -query $query -max_target_seqs 10 -out blast_out/$out_file.out -outfmt '$outfmt' -num_threads 32" "$out_file" 1 16 "compute" 4
}

maize_db="blastdb/maize_v3.longest.aa"
maize_fa="fa/maize_v3.longest.aa.fa"
for f in $@
do
	blast_plant $f $maize_db
	blast_maize $f $maize_fa
done
