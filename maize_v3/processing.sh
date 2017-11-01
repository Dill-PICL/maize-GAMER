fasta_formatter -i Zea_mays.AGPv3.23.pep.all.fa -o maize_v3.aa.fa
cat names.tmp | sed -e 's/_P.*//g' -e 's/FGP/FG/g' | sort | uniq > genes.tmp
./get_longest.sh genes.tmp > maize_v3.longest
fgrep -A1 -f maize_v3.longest.aa maize_v3.aa.fa | grep -v '\-\-' > maize_v3.longest.aa.fa
makeblastdb -in maize_v3.longest.aa.fa -dbtype prot -hash_index -out ../blastdb/maize_v3_aa  -title maize_v3_aa
