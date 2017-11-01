#input="tair/maize_tair.go.txt"
for input in $@
do
	#input="ouput/maizev3_aa_results.GO"
	output=`basename $input | sed 's/go.txt/gaf/g'`
	qsub=`which qsub`
	job=`basename $input | cut -f 2 -d "."`
	command="clean_results.py -i $input -o go.obo -g gaf/$output -d $job"
	if [ -z $qsub ]
	then
		echo "python clean_results.py -s $input -o go.obo -g gaf/$output -d $job"
		python $command
	else
	  qsub_create " \
	source ~/load_modules.sh
	source activate_venv.sh
	python $command -n 8" "$job.2gaf" 1 32 8 48
	fi
done
