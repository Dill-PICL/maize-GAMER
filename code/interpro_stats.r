data <- read.table("../interpro_out/maize_v3.interpro.go.txt",header=F,sep="\t",stringsAsFactors = F,quote = "\"")
gene_go <- NULL
tmp <- apply(data,1,function(x){
  splits <- unlist(strsplit(x[14],'\\|'))
  #gene_go <<- rbind(gene_go,cbind(x[1],splits))
  cbind(x[1],splits)
})
head(tmp)

gene_go <- NULL
tmp2 <- lapply(tmp,function(x){
  gene_go <<- rbind(gene_go,x)
})


#cbind(data[10,1],unlist(strsplit(data[10,14],"\\|")))
dim(gene_go)
