source("code/plot_tools.r")
source("code/aigo_tools.r")
source("code/gaf_tools.r")
source("code/plot_eval.r")


exist_datasets = fread("exist_datasets.txt")
comb_datasets = fread("comb_datasets.txt")
all_datasets = rbind(comb_datasets,exist_datasets)
all_datasets
data_order = fread("dataset_order.txt",header = F)$V1

all_gaf = apply(all_datasets,1,function(x){
    infile = paste("nr_data/",x["file"],sep="")    
    
    print(infile)
    tmp_in = read_gaf(infile)
    tmp_in$tool = x["dataset"]
    tmp_in
})

all_gaf_dt = do.call(rbind,all_gaf)
tmp_annots = all_gaf_dt[,list(value=.N,measure="num_annots"),by=list(assigned_by,aspect)]
tmp_annots = tmp_annots[,tool:=assigned_by][,-1,with=F]
tmp_annots

all_eval = apply(all_datasets,1,function(x){
    infile = basename(x["file"])
    infile = gsub("gaf","csv",basename(x["file"]))
    infile = gsub("maize_v3","maize_v3.aigo_eval",infile)
    infile = paste("tables/",infile,sep="")
    print(infile)
    tmp_in = fread(infile)
    tmp_in$tool = x["dataset"]
    tmp_in
})

#all_eval_dt[db_object_symbol==gene]#[,.(avg_fscore,tool)]
#all_eval_dt[db_object_symbol==gene][,.(max_fscore,tool)]

all_eval_dt = do.call(rbind,all_eval)
#all_eval_dt = rbind(all_eval_dt,agg_eval)
all_eval_dt

all_eval_dt = all_eval_dt[!(tool=="FANN-GO" & aspect=="C")]
all_eval_dt

tmp_eval = all_eval_dt[,list(value=mean(avg_fscore),measure="avg_fscore"),by=list(tool,aspect)]
tmp_eval

all_meas = apply(all_datasets,1,function(x){
    #infile=basename(x["file"])
    infile = paste("nr_data/measure/",x["file"],sep="")    
    
    infile=gsub("gaf","tdf",infile)
    print(infile)
    tmp_data = fread(infile)
    tmp_data$tool = x["dataset"]
    tmp_data
})

all_meas_dt = do.call(rbind,all_meas)
#all_meas_dt = rbind(all_meas_dt, comb_meas)
all_meas_dt[aspect!="All"]$aspect = aspect2one(all_meas_dt[aspect!="All"]$aspect)

tmp_meas = all_meas_dt[aspect!="All" & measure %in% c("coverage")]
tmp_meas


plot_data = rbind(tmp_annots,tmp_eval,tmp_meas)
plot_data = merge(plot_data,all_datasets[,-3,with=F],by.x="tool",by.y="dataset")
plot_data$tool = factor(plot_data$tool,levels=data_order)
plot_data$measure = factor(plot_data$measure, levels=c("coverage","num_annots","avg_fscore"),labels = c(bquote(Coverage ~("%")),bquote("#" ~ of ~ Annotations),"hF[1]"))
plot_data$aspect = factor(plot_data$aspect, levels=c("C","F","P"), labels=c("Cellular~Component","Biological~Process","Molecular~Function"))

plot_data[Type=="Aggregate",Type:="maize-GAMER"]
plot_data[tool=="Aggregate",tool := "maize-GAMER"]

# measures = list("Coverage (%)","# of Annotations","hF[1]")
# names(measures) = c("coverage","num_annots","avg_fscore")
# 
# meas_name = function(meas){
#     lapply(meas,function(x){
#         print(parse(text=measures[x]))    
#     })
#     return(measures[meas])
# }

#cbpallete = c("#377eb8","#4daf4a","#e41a1c")
cbpallete = c("#1b9e77","#d95f02", "#fdcdac","#e7298a")

p = ggplot(plot_data,aes(x=tool,y=value,fill=tool))
p = p + geom_bar(stat="identity",size=0.5,color="#000000")
p = p + xlab("Dataset") 
# p = p + scale_y_continuous(labels = format_annots)
p = p + scale_fill_manual(values=cbpallete) + theme_bw(base_size = 18) + scale_y_continuous(labels=comma)
# p = p + theme(axis.text.x = element_text(angle = 20,hjust = 1,vjust = 1),axis.title.y = element_blank(),legend.position = "bottom",legend.title = element_blank())
p = p + theme(axis.text.x = element_blank(),axis.title.y = element_blank(),legend.position = "bottom",legend.title = element_blank())
p = p + facet_grid(measure~aspect,scales = "free_y",labeller=label_parsed,switch = "y")
p

# print(p)

ppt_f = paste("plots/ppt/results-exist.png",sep="")
poster_f = paste("plots/png/results-exist.png",sep="")
ggsave(ppt_f,width = 8,height=8,dpi=300,units = "in")
ggsave(poster_f, width = 9,height=8,dpi=300,units = "in")

write.table(dcast(plot_data,measure+tool~aspect,value.var = "value"),"tables/disc_plot_data.csv",row.names = F,sep = "\t")