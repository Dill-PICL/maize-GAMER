./run_blast.sh
./run_hmmer.sh

for f in hmmer/*hmmer
do
    zip -9 $f.zip $f
done

for f in blast/*blast
do
    zip -9 $f.zip $f
done
