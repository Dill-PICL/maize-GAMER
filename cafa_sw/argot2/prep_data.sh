# zcat pfam/*.gz > pfam/Pfam-AB.hmm
# hmmpress pfam/Pfam-AB.hmm
# zcat uniprot/*.gz > uniprot/uniprot_all.fasta
split -l 10000 --numeric-suffixes=1 --additional-suffix=".fa" ../../maize_v3/maize_v3.longest.aa.fasta maize_v3_5k/maize_v3.longest.
