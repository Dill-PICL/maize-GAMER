for f in $@
do
	echo $f
	out=`basename $f | sed 's/.fa$//g'`
	echo blastp -outfmt '6 qseqid sseqid evalue' -num_threads 16 -query $f -db uniprot/uniprot_all.fasta -out "blast/$out.blast"
done
