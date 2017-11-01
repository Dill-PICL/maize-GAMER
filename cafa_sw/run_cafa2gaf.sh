#!/bin/bash
gold="nr_data/gold.gaf"
obo="obo/go.obo"
cafa2gaf () {
	qsub=`which qsub`
	job="cafa2gaf"
	command="cafa2gaf.r"
	echo $command
	if [ -z $qsub ]
	then
		echo $command
		Rscript $command
	else
		rm BATCH*
		echo $command
  		qsub_create " \
		source load_modules.sh
		Rscript $command" "$job" 1 32 8 48
	fi
}

cafa2gaf
