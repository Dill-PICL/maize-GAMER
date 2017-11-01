#outfmt="6 qseqid sseqid qlen qstart qend slen sstart send evalue bitscore score length pident nident gaps"
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
DB="../cafa_sw/PANNZER_RELEASE/db/UNIPROT"
outfmt="\"6 qseqid sseqid qlen qstart qend slen sstart send evalue bitscore score length pident nident gaps\""
num_jobs=`qstat -u kokul | grep blast | wc -l`
max_jobs=4
if [ $num_jobs -lt $max_jobs ]
then
	while [ $num_jobs -lt 4  ]
	do
		add_jobs=`expr 4 - $num_jobs`
		files=`ls archive/* | head -n 1`
		for f in $files
		do
			in=`echo $f | sed 's/archive/proc_asn/g'`
			out=`basename $f | sed 's/.asn//g'`
			job=`echo $out | sed 's/.*_/blast_/g'`
			mv $f proc_asn
			qsub_create "export BLASTDB='/home/kokul/work_dir/lawlab/go_annotation/trial2/cafa_sw/PANNZER/db'\nblast_formatter -archive $in -outfmt 5 -out xml/$out.xml & \nblast_formatter -archive $in -outfmt $outfmt -out tsv/$out.tsv" "$job" 1 4 8 1
		done
		rm *.job
		num_jobs=`qstat -u kokul | grep blast | wc -l`
		#num_jobs=$[num_jobs+1]
	done
else
	echo "$num_jobs/$max_jobs Jobs are already queued"
fi
