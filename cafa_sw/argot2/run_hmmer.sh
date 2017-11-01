for f in $@
do
	echo $f
	out=`basename $f | sed 's/.fa$//g'`
	echo hmmscan --cpu 32 --tblout hmmer/$out.hmmer pfam/Pfam-AB.hmm  $f
done
