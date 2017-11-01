obo="obo/go.obo"
rm_redundancy(){
	qsub=`which qsub`
	for f in $@
	do
		if [ -a $f ]
		then
			tool=`basename $f | sed -e 's/.*maize_v3.//g' -e 's/.gaf$//'`
			command="rm_red_annot.r $f $obo"
			if [ -z $qsub ]
			then
				echo $command
				Rscript $command
			else
				rm BATCH*
				echo $command
		  		qsub_create "\
				source load_modules.sh
				Rscript $command" "$tool.rm_red" 1 32 8 8
			fi
		else
			echo "The file $f doesn't exist"
		fi
	done
}


if [ -z $@ ]
then
	echo "Do you want to remove redundancy on all files in red_data folder?"
	echo ""
	read confirm
	if [ "$confirm" == "Y" ] || [ "$confirm" == "y" ]
	then
		infiles=`find uniq_data -iname "*gaf"`
		rm_redundancy $infiles
	else
		echo "Not running the rm_redundancy"
	fi
else

	rm_redundancy $@
fi
