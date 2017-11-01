in_args = commandArgs(T)
if(length(in_args) != 5){
    warning("The number of input arguments are not correct")
    warning("5 input arguments required in the following order")
    warning("plot_pos_score.r annot_file gold_file go_file tool num_cores")
    stop("Please check inputs and try again")
}

cat(in_args,"\n")
annot_file = in_args[1]
gold_file  = in_args[2]
go_file  = in_args[3]
tool_name = in_args[4]
num_cores = as.numeric(in_args[5])
#stop()

source("code/filter_cafa.r")

filter_cafa(annot_file,gold_file,go_file,tool_name,num_cores)