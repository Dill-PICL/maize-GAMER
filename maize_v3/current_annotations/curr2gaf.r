library("reshape2")

source("code/gaf_tools.r")
source("code/obo_tools.r")
source("code/phyto2gaf.r")
source("code/gramene2gaf.r")

gaf_cols = fread("../../gaf_cols.txt",header = F)$V1
gaf_date = format(Sys.time(),"%m%d%Y")
obo_data = check_obo_data("go.obo")
refset = fread("../maize_v3.refset.txt",header = F)$V1

phyto_in = "phytozome/raw/Zmays_284_5b+.annotation_info.txt"
phyto_out = "phytozome/gaf/maize_v3.phytozome.gaf"
phyto2gaf(phyto_in,phyto_out)

gramene_in = "gramene/raw/zea_mays_release49.gaf"
gramene_out = "gramene/gaf/gramene49.gaf"
gramene2gaf(gramene_in,gramene_out)