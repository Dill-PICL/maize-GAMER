library("data.table")
library("ggplot2")
library("reshape2")
library("gridExtra")

install.packages("data.table")
install.packages("ggplot2")
install.packages("reshape2")
install.packages("gridExtra")

in_dirs <- dir("datasets",full.names = T)
base_dirs <- paste(in_dirs,"/tables",sep="")
in_files <- dir(base_dirs,full.names = T)

x <- in_files[1]
x
tmp <- lapply(in_files,function(x){
    method   <- unlist(strsplit(dirname(x),"/"))[2]
    test_set <- unlist(strsplit(basename(x),"_"))[3]
    ont      <- unlist(strsplit(basename(x),"[_.]"))[4]
    tmp_perf <- read.table(x,header = T,sep = "\t")
    
    pr <- mean(tmp_perf$num_tp/(tmp_perf$num_tp+tmp_perf$num_fp))
    rc <- mean(tmp_perf$num_tp/(tmp_perf$num_tp+tmp_perf$num_fn))
    f_stat <- 2*pr*rc/(pr+rc)
    num_genes <- length(unique(tmp_perf$gene))
    c(method,test_set,ont,pr,rc,f_stat,num_genes)
})

all_pr_rc <- data.frame(do.call(rbind,tmp))


all_pr_rc[,4:6] <- apply(all_pr_rc[,4:6],2,function(x){as.numeric(as.character(x))})
colnames(all_pr_rc) <- c("method","test_set","ont","pr","rc","f_stat","num_genes")
all_pr_rc
plot_data <- melt(all_pr_rc[,c(1:3,6,7)],id.vars = c("method","test_set","ont","num_genes"))
plot_data$num_genes <- as.numeric(as.character(plot_data$num_genes))
plot_data$value <- round(as.numeric(plot_data$value),2)
plot_data
plot_data$method <- factor(plot_data$method,levels = c("tair","uniprot","interpro","argot2","fanngo","pannzer","gramene"))
xlbls <- c("TAIR","Plant","InterProScan","Argot2","FANNGO","PANNZER","Gramene")

tool_cats <- read.table("annot_tool_cat.txt",header = T,sep = "\t",as.is = )
plot_data_cat <- merge(plot_data,tool_cats,by.x = "method",by.y = "tool")
plot_data_cat$category <- factor(plot_data_cat$category,levels=c("BLAST","InterProScan","CAFA","Gramene"))


mz_gdb <- plot_data_cat[plot_data$test_set=="maizegdb",]
mz_gdb

cbbpallette = c("#FFF2CC","#DEEBF7","#E2F0D9","#FBE5D6")
#png("plots/perf.plot.png",width=15.5,height=6,units = "in",res = 300)
p <- ggplot(mz_gdb,aes(x=method,y=value,ymax=1.05,fill=category))
p <- p + geom_bar(stat = "identity",position = "dodge",width=0.8,color="black")
p <- p + geom_text(aes(label=num_genes),vjust=-0.3,position = position_dodge(width=1),size=4)
p <- p + facet_grid(.~ont)
#p <- p + scale_fill_brewer(labels = xlbls,type = "qual")
p <- p + theme(axis.text.x = element_text(angle=45,vjust=0.6),legend.position="right")
p <- p + scale_x_discrete("Tool", labels=xlbls) + ylim(0,1.2)
p <- p + scale_fill_manual(values=cbbpallette)
p <- p + ggtitle("Evaluations based on Manual Annotations from MaizeGDB")
p <- p + ylab("F-Score")
p

png("plots/perf.plot.png",width = 13.6,height = 5,units = "in",res = 300)
print(p)
dev.off()


uniprot_test <- plot_data[plot_data$test_set=="uniprot",]
#png("plots/perf.plot.png",width=15.5,height=6,units = "in",res = 300)
uniprot_plot <- ggplot(uniprot_test,aes(x=method,y=value,ymax=1.05,fill=method))
uniprot_plot <- uniprot_plot + geom_bar(stat = "identity",position = "dodge",width=0.8)
uniprot_plot <- uniprot_plot + geom_text(aes(label=num_genes),vjust=-0,position = position_dodge(width=1),size=4)
#p <- p + geom_bar(stat = "identity")
uniprot_plot <- uniprot_plot + facet_grid(.~ont)
#uniprot_plot <- uniprot_plot + guides(fill=F)
uniprot_plot <- uniprot_plot + theme(axis.text.x = element_text(angle=90,vjust=0.5))
uniprot_plot <- uniprot_plot + scale_fill_brewer(labels = xlbls,type = "qual")
uniprot_plot <- uniprot_plot + guides(fill=guide_legend(title="Tool"))
uniprot_plot <- uniprot_plot + scale_x_discrete("Tool", labels=xlbls)
#p <- p + scale_fill_gradient(breaks=seq(0,500,100))
uniprot_plot <- uniprot_plot + ggtitle("B) Evaluations based on Uniprot test dataset")
uniprot_plot <- uniprot_plot + ylab("F-Score") + ylim(0,1.2)
uniprot_plot
#dev.off()

#png("plots/perf.plot.png",width = 15.5,height = 5,units = "in",res = 300)
#grid.arrange(p,uniprot_plot,ncol=2,widths=c(7,8.5))
#dev.off()
