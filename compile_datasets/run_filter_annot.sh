#!/bin/bash
gold="nr_data/gold.gaf"
obo="obo/go.obo"
filter_annot () {
	qsub=`which qsub`
	for f in $@
	do
		if [ -a $f ]
		then
			tool=`basename $f | sed -e 's/-.\+//g'`
			job=`basename $f | sed -e 's/\.[^.]\+$//g'`
			command="filter_cafa_annots.r $f $gold $obo $tool"
			echo $command
			if [ -z $qsub ]
			then
				echo $command
				Rscript $command 2
			else
				rm SBATCH*
				echo $command
		  		sbatch_create "source load_modules.sh && Rscript $command 8" "$job.filt" 1 16 8000  48
			fi
		else
			echo "The file $f doesn't exist"
		fi
	done
}


if [ -z $@ ]
then
	echo "Do you want to filter all files in cafa folder?"
	echo ""
	read confirm
	if [ "$confirm" == "Y" ] || [ "$confirm" == "y" ]
	then
		infiles=`find . -iname "*-0.0.gaf" -follow`
		filter_annot $infiles
	else
		echo "Not running the eval"
	fi
else

	filter_annot $@
fi
