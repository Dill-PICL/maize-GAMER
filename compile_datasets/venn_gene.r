#install.packages("devtools")
library(devtools)

#install_github("js229/Vennerable")
library(Vennerable)
library(scales)

source("code/gaf_tools.r")
source("code/obo_tools.r")
source("code/gen_utils.r")
source("code/get_robust.r")
source("code/get_nr_dataset.r")

datasets = fread("datasets.txt")
#obo="obo/go.obo"
all_data = apply(datasets,1,function(x){
    infile = paste("nr_data/",x["file"],sep="")
    print(infile)
    read_gaf(infile)
})
all_gaf = do.call(rbind,all_data)

all_gaf = merge(all_gaf, datasets[,1:2,with=F],by.x = "assigned_by",by.y="dataset")
unique(all_gaf$db)

uniq_genes = all_gaf[,list(genes=list(unique(db_object_id))),by=Type]
tmp_out = as.list(uniq_genes$genes)
names(tmp_out) = uniq_genes$Type


cbpallete = c("#FFF2CC","#DEEBF7","#E2F0D9","#fdcdac")
gene_gamer_venn = Venn(tmp_out)
c3 = compute.Venn(gene_gamer_venn,type="circles",doEuler = F,doWeights = F)
gp = VennThemes(c3,colourAlgorithm = "signature")
gp
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

c3@IndicatorWeight[,".Weight"] = comma(c3@IndicatorWeight[,".Weight"])

svg("plots/svg/gene_gamer_venn.svg",width = 5,height = 5)
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
disc_data_dt = do.call(rbind,disc_data)
disc_data_dt = disc_data_dt[db_object_id %in% maize_refset]

disc_gaf = merge(disc_data_dt, all_datasets[,1:2,with=F],by.x = "assigned_by",by.y="dataset")
disc_gaf[assigned_by=="Aggregate"]$assigned_by = "maize-GAMER"
disc_uniq_genes = disc_gaf[,list(genes=list(unique(db_object_id))),by=assigned_by]
disc_uniq_list  = as.list(disc_uniq_genes$genes)
names(disc_uniq_list) = disc_uniq_genes$assigned_by

disc_uniq_list[["Gramene"]][!disc_uniq_list[["Gramene"]] %in% disc_uniq_list[["maize-GAMER"]]]

length(unique(disc_gaf[assigned_by=="maize-GAMER"]$db_object_id))
length(unique(disc_gaf[assigned_by=="Gramene"]$db_object_id))
length(unique(disc_gaf[assigned_by=="Phytozome"]$db_object_id))

cbpallete = c("#d95f02","#1b9e77", "#fdcdac","#e7298a")

gene_disc_venn = Venn(disc_uniq_list)
c3 = compute.Venn(gene_disc_venn,type="circles",doEuler = F,doWeights = F)
gp = VennThemes(c3,colourAlgorithm = "signature")
gp
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

c3@IndicatorWeight[,".Weight"] = comma(c3@IndicatorWeight[,".Weight"])

svg("plots/svg/gene_disc_venn.svg",width = 5,height = 5)
plot(c3,gpList =gp,  show = list(FaceText = "weight", SetLabels = F, Faces = T, DarkMatter = F))
dev.off()
