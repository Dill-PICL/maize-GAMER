zcat blastdb/*.gz > blastdb/uniprot_all.fa
makeblastdb -in blastdb/uniprot_all.fa -dbtype 'prot' -out blastdb/uniprot_all
