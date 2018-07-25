#install.packages("devtools")
library(devtools)
library(grid)

#source("https://bioconductor.org/biocLite.R")
#biocLite("graph")
#biocLite("RBGL")
library("graph")
library("RBGL")
library("scales")

#install_github("js229/Vennerable")
library(Vennerable)

source("code/gaf_tools.r")
source("code/obo_tools.r")
source("code/gen_utils.r")
source("code/get_robust.r")
source("code/get_nr_dataset.r")
source("code/plot_helper.r")

datasets = fread("datasets.txt")
#comb_datasets = fread("comb_datasets.txt")

#datasets = rbind(datasets,comb_datasets)
#obo="obo/go.obo"
all_data = apply(datasets,1,function(x){
    infile = paste("nr_data/",x["file"],sep="")
    print(infile)
    read_gaf(infile)
})
all_gaf = do.call(rbind,all_data)
unique(all_gaf$assigned_by)

obo_data = check_obo_data("obo/go.obo")

filt_data = merge(all_gaf,datasets,by.x = "assigned_by",by.y="dataset")
filt_data = unique(filt_data[,.(term_accession,Type)])

types = unique(filt_data$Type)
tmp_go_terms = lapply(unique(filt_data$Type),function(x){
    tmp_out = unlist(obo_data$ancestors[filt_data[Type==x]$term_accession])
    unique(tmp_out)
})
names(tmp_go_terms) = types

cbpallete = c("#FFF2CC","#DEEBF7","#E2F0D9","#fdcdac")
#vignette("Venn")
go_venn <- Venn(tmp_go_terms)
go_venn

c3 = compute.Venn(go_venn,type="circles",doEuler = F,doWeights = F)
gp = VennThemes(c3,colourAlgorithm = "signature")
gp = venn_face_col(gp,cbpallete)

gp$Set$Set1$lwd = 2
gp$Set$Set2$lwd = 2
gp$Set$Set3$lwd = 2
#gp$Set$Set1$col = cbpallete[1]
#gp$Set$Set2$col = cbpallete[2]
#gp$SetText$Set3$col = cbpallete[3]
#gp$SetText$Set1$fill = "#FF0000"
gp$Set$Set3$col = "#000000"
gp$Set$Set2$col = "#000000"
gp$Set$Set1$col = "#000000"
gp$SetText$Set1$col = "#000000"
gp$SetText$Set2$col = "#000000"
gp$SetText$Set3$col = "#000000"
gp$SetText$Set1$fill = "#000000"

c3@IndicatorWeight[,".Weight"] = comma(c3@IndicatorWeight[,".Weight"])

svg("plots/svg/go_gamer_venn.svg",width = 5,height = 5)
plot(c3,gpList =gp,  show = list(FaceText = "weight", SetLabels = F, Faces = T, DarkMatter = F))
dev.off()


comb_datasets = fread("comb_datasets.txt")
exist_datasets = fread("exist_datasets.txt")

maize_refset = fread("maize_v3.refset.txt",header = F)$V1
all_datasets = rbind(comb_datasets,exist_datasets)

disc_data = apply(all_datasets,1,function(x){
    infile = paste("nr_data/",x["file"],sep="")
    tmp_in = read_gaf(infile)
    tmp_in$assigned_by = x["dataset"]
    tmp_in
})
all_gaf = do.call(rbind,disc_data)
all_gaf = rbind(all_gaf,gold)

all_gaf = all_gaf[db_object_id %in% maize_refset]

raw_ancestors = obo_data$ancestors[all_gaf$term_accession]
ancest_num = lapply(raw_ancestors,length)
tmp_gaf = cbind(all_gaf,ancest_num=unlist(ancest_num))

tmp_gaf[assigned_by=="MaizeGDB" & aspect!="C"]$aspect

p = ggplot(tmp_gaf,aes(x=aspect,y=ancest_num,fill=assigned_by))
p = p + geom_boxplot(position = "dodge")
p
ggsave("plots/exist-specificity.png")


wt_out = pairwise.wilcox.test(tmp_gaf$ancest_num,tmp_gaf$assigned_by,paired = F,alternative="greater")
wt_out
spec_tmp = tmp_gaf[,list(specificity=mean(ancest_num)),by=list(assigned_by,aspect)]
spec_tmp
write.table(dcast(spec_tmp,aspect~assigned_by),"tables/dataset-specificity.csv",sep = "\t",quote = F,row.names = F)

filt_data = merge(all_gaf,all_datasets,by.x = "assigned_by",by.y="dataset")
filt_data[assigned_by=="Aggregate"]$assigned_by = "maize-GAMER"
filt_data = unique(filt_data[,.(term_accession,assigned_by)])
types = unique(filt_data$assigned_by)

tmp_go_terms = lapply(unique(filt_data$assigned_by),function(x){
    tmp_out = unlist(obo_data$ancestors[filt_data[assigned_by==x]$term_accession])
    unique(tmp_out)
})
names(tmp_go_terms) = types


#cbpallete = c("#FFF2CC","#DEEBF7","#E2F0D9","#fdcdac")
cbpallete = c("#d95f02","#1b9e77", "#fdcdac","#e7298a")
#vignette("Venn")
go_venn <- Venn(tmp_go_terms)
c3 = compute.Venn(go_venn,type="circles",doEuler = F,doWeights = F)
gp = VennThemes(c3,colourAlgorithm = "signature")
gp = venn_face_col(gp,cbpallete)
gp$Set$Set1$lwd = 2
gp$Set$Set2$lwd = 2
gp$Set$Set3$lwd = 2
#gp$Set$Set1$col = cbpallete[1]
#gp$Set$Set2$col = cbpallete[2]
#gp$SetText$Set3$col = cbpallete[3]
#gp$SetText$Set1$fill = "#FF0000"
gp$Set$Set3$col = "#000000"
gp$Set$Set2$col = "#000000"
gp$Set$Set1$col = "#000000"
gp$SetText$Set1$col = "#000000"
gp$SetText$Set2$col = "#000000"
gp$SetText$Set3$col = "#000000"

gp$SetText$Set1$fill = "#000000"

c3@IndicatorWeight[,".Weight"] = comma(c3@IndicatorWeight[,".Weight"])

svg("plots/svg/go_disc_venn.svg",width = 5,height = 5)
plot(c3,gpList =gp,  show = list(FaceText = "weight", SetLabels = F, Faces = T))
dev.off()



filt_data = merge(all_gaf,datasets,by.x = "assigned_by",by.y="dataset")
tool_go = filt_data[Type=="Mix-Method" & aspect=="C",.(term_accession,assigned_by)]
types = unique(tool_go$assigned_by)
tool_go_terms = lapply(types,function(x){
    tmp_out = unlist(obo_data$ancestors[tool_go[assigned_by==x]$term_accession])
    unique(tmp_out)
})
names(tool_go_terms) = types
tool_go_venn <- Venn(tool_go_terms)
c3 = compute.Venn(tool_go_venn,type="circles",doEuler = F,doWeights = F)
grid.newpage()
plot(c3,  show = list(FaceText = "weight", SetLabels = T, Faces = T))

lapply(tool_go_terms,length)



tool_go = filt_data[,.(term_accession,assigned_by,aspect,Type)]
tools = unique(tool_go$assigned_by)
go_count = length(unique(obo_data$id))

tool_term_count = tool_go[order(aspect,Type),list(count=length(unique(unlist(obo_data$ancestors[unique(term_accession)])))),by=list(aspect,assigned_by,Type)]

tool_term_count[,rich:=count/go_count*100]
tool_term_count
tool_term_count

tool_term_table = dcast(tool_term_count,aspect~assigned_by,value.var = "count")
tool_term_table
write.table(tool_term_table,"tables/go_term_count.csv",sep = "\t",quote = F,row.names = F)
?dcast
