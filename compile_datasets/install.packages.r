library("data.table")
all_libraries = fread("R_packages.txt",header=F,sep="\t")$V1
install.packages(all_libraries,repos="https://mirror.las.iastate.edu/CRAN/")
