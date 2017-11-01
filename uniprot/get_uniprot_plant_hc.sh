#this script is to download the hc annotations from uniprot for all plant species
#1) This step will download the gaf file that has al high confidence evidence codes
wget -O annot/uniprot_hc_plant.gaf "http://www.ebi.ac.uk/QuickGO/GAnnotation?format=gaf&limit=-1&q=!evidence=IEA,ND,NAS&tax=33090"
#2) This step will download the fasta file that has sequences for all records with high confidence ev codes
wget -O fa/tmp.fa "http://www.ebi.ac.uk/QuickGO/GAnnotation?format=fasta&limit=-1&q=!evidence=IEA,ND,NAS&tax=33090"
#2) Need to change the headers of the downloaded fasta file so that we can match it with the gaf
cat fa/tmp.fa | sed -e 's/^>[^|]\+|/>/g' -e 's/|.\+//g' >  fa/uniprot_hc_plant.fa
rm fa/tmp.fa

cat annot/uniprot_hc_plant.gaf | cut -f 13 | tail -n +3 > annot/taxon.txt
#http://www.ebi.ac.uk/QuickGO/GAnnotation?format=gaf&limit=-1&tax=33090
