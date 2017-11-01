genome="maize_b73_agp4"

evlab_job (){
	num_thread=4
	command='matlab -nojvm -nodisplay -nosplash < code/run_fanngo.m > fanngo.log'
	$command
}
condo_job (){
	job="FANN-GO"
	num_thread=16
	command='source load_modules.sh\nmatlab -nojvm -nodisplay -nosplash < code/run_fanngo.m > fanngo.log'
	create_dill_job "$command" $job 1 $num_thread "compute" 72
}


sbatch=`which sbatch`
echo "$sbatch"
if [ -z "$sbatch" ]
then
	evlab_job
else
	condo_job
fi
