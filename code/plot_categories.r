#source("https://bioconductor.org/biocLite.R")
#biocLite("GO.db")
library("GO.db")
library("reshape2")
library("data.table")
library("scales")
library("ggplot2")

#in_file = pred_file
#Read data into R
plot_cats <- function(in_file,ont_plot,gene_plot) {
    #print(in_file)
    #print(ont_plot)
    #print(gene_plot)
    data <-
        read.table(
            in_file,as.is = T,sep = "\t",quote = "",header = T
        )
    
    if(dim(data)[1]>2){
        data <- data[,1:2]
    }
    colnames(data) <- c("gene_id","go_id")
    
    #Figure out the Gene ontology
    ont_list <- Ontology(as.character(data$go_id))
    #ont_list <- unlist(lapply(data$go_id,function(x) {
    #    c(Ontology(x))
    #}))
    
    data_filt <- data[!is.na(ont_list),]
    ont_list <- ont_list[!is.na(ont_list)]
    data_dt <- data.table(cbind(data_filt,ont = ont_list))
    data_dt
    
    plot_dt <-
        data_dt[,list(
            annotations = .N,genes = length(unique(gene_id)),go_terms = length(unique(go_id))
        ),by = ont]
    plot_data <- melt(plot_dt,"ont")
    plot_data[plot_data$variable!="annotations"]
    
    #Plot simple bar graph
    svg(
        ont_plot,width = 4,height = 2.8
    )
    p <- ggplot(data_dt,aes(x = ont,fill = ont))
    p <- p +  geom_bar(stat = "count")
    p <- p + scale_y_continuous(labels = comma)
    #p <- p + coord_polar(theta="y",start=0)
    #p <- p + scale_y_continuous(breaks=ont_pie$breaks,labels=ont_pie$label) + scale_fill_brewer(type = "qual",palette = 1)
    #p <- p + theme(axis.text.x=element_text(size = 6,angle=30),panel.background=element_rect(fill = "#FFFFFF"))
    p <-
        p + geom_text(stat = "count",aes(label = ..count..,y = (..count..*0 + 100),vjust=0),size = 4)
    p <- p + labs(title = "",x = "",y = "# of Unique Annotations")
    p <- p + scale_fill_discrete(guide=guide_legend(title="Ontology"))
    print(p)
    dev.off()
    
    #Plot simple bar graph
    svg(
        gene_plot,width = 4,height = 2.8
    )
    p <- ggplot(plot_data[plot_data$variable!="annotations"],aes(ont,value,fill = variable))
    p <- p +  geom_bar(stat="identity",position="dodge")
    #p <- p + scale_y_discrete(labels = comma)
    #p <- p + coord_polar(theta="y",start=0)
    #p <- p + scale_y_continuous(breaks=ont_pie$breaks,labels=ont_pie$label) + scale_fill_brewer(type = "qual",palette = 1)
    #p <- p + theme(axis.text.x=element_text(size = 6,angle=30),panel.background=element_rect(fill = "#FFFFFF"))
    p <- p + geom_text(aes(label=value,y=value+250),position=position_dodge(width=1),size = 2)
    #p <- p + facet_grid(.~ont)
    p <- p + labs(title = "",x = "Ontology",y = "Count")
    #p <- p + theme(axis.text.x=element_text(angle=45,vjust = 1,hjust = 0))
    p <- p + theme_linedraw()
    p <- p + scale_fill_discrete(guide=guide_legend(title=NULL),labels=c("Genes","GO Terms"))
    p
    print(p)
    dev.off()
}