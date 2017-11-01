#input="tair/maize_tair.go.txt"
for input in $@
do
	#input="ouput/maizev3_aa_results.GO"
	#output=`basename $input | sed 's/go.txt/gaf/g'`
	output="maize_v3.phytozome.gaf"
	qsub=`which qsub`
	if [ -z $qsub ]
	then
		echo "python clean_results.py -s $input -o go.obo -g gaf/$output"
		python clean_results.py -i $input -o go.obo -g gaf/$output
	else
	  qsub_create " \
	source ~/load_modules.sh
	source activate_venv.sh
	python clean_results.py -s $input -o go.obo -g gaf/$output -n 8" "phytozome2gaf" 1 32 8 48
	fi
done
