# install.packages("devtools")
# library(devtools)

# install_github("js229/Vennerable")
library(Vennerable)

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
all_gaf

uniq_genes = all_gaf[,list(genes=list(unique(db_object_id))),by=Type]
tmp_out = as.list(uniq_genes$genes)
names(tmp_out) = uniq_genes$Type


#vignette("Venn")
#gene_gamer_venn <- Venn(tmp_out)
png("plots/gene_gamer_venn.png",width = 5,height = 5,units = "in",res = 600)
c3 = compute.Venn(gene_gamer_venn,type="circles",doEuler = F,doWeights = F)
gp = VennThemes(c3,colourAlgorithm = "sequential")
gp$Set$Set1$col = "#E41A1C"
gp$Set$Set2$col = "#E41A1C"
gp$Set$Set3$col = "#E41A1C"
gp$SetText$Set1$col = "#E41A1C"
gp$SetText$Set2$col = "#E41A1C"
gp$SetText$Set3$col = "#E41A1C"
plot(c3,gpList =gp,  show = list(FaceText = "weight", SetLabels = T, Faces = F))

#plot(gene_gamer_venn,doWeights=F,show=list(DarkMatter = F,Faces=F))
dev.off()

comb_datasets = fread("comb_datasets.txt")
exist_datasets = fread("exist_datasets.txt")
maize_refset = fread("maize_v3.refset.txt",header = F)$V1

length(unique(disc_data_dt[!disc_data_dt$db_object_id %in% maize_refset]$db_object_id))
length(unique(disc_data_dt[!disc_data_dt$db_object_id %in% maize_refset]$db_object_id))

all_datasets = rbind(comb_datasets,exist_datasets)

disc_data = apply(all_datasets,1,function(x){
    infile = paste("disc_data/",x["file"],sep="")
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

#gene_disc_venn = Venn(disc_uniq_list)
png("plots/gene_disc_venn.png",width = 5,height = 5,units = "in",res = 600)
#plot(gene_disc_venn,doWeights=F,show=list(DarkMatter = F,Faces=F,colourAlgorithm="signature"))
c3 = compute.Venn(gene_disc_venn,type="circles",doEuler = F,doWeights = F)
gp = VennThemes(c3,colourAlgorithm = "sequential")
plot(c3,gpList =gp,  show = list(FaceText = "weight", SetLabels = T, Faces = F))
dev.off()
