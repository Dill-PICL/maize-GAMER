library("data.table")
library("ggplot2")
library("reshape2")
library("tools")

source("code/filter_cafa.r")

ont_code = list(MF="F",BP="P",CC="C")

in_dir="eval"
tools = dir(in_dir)

tools_data=lapply(tools,function(tool){
    read_data(tool)
})

names(tools_data) = tools
tools_data$argot2$data
tools_data$argot2$data[th==0 & ont == "MF"]



tmp_avg_f_score = lapply(tools_data,function(x){
    return(x$avg_fscore)
})
tmp_avg_f_score

all_avg_fscore = do.call(rbind,tmp_avg_f_score)


tmp_idx = all_avg_fscore[,.I[tool == "fanngo" & ont == "CC"]]
filt_avg_fscore = all_avg_fscore[!tmp_idx]



fscore_plot = ggplot(filt_avg_fscore,aes(x=th,y=avg_fscore,color=tool))
fscore_plot = fscore_plot + geom_line()
fscore_plot = fscore_plot + facet_grid(ont~.)
fscore_plot = fscore_plot + ylab("Average F-Measure") + xlab("Annotation Score")
fscore_plot
ggsave("plots/annot_score_vs_avg_f_score.png",scale = 1)

max_fscore_th = filt_avg_fscore[,list(max_fscore=max(avg_fscore),th=th[which.max(avg_fscore)]),by=list(tool,ont)]
min_fscore_th = max_fscore_th[,list(min_th=min(th)),by=tool]

write.table(max_fscore_th,"tables/max_cafa_fscore.csv",quote = F,sep = "\t",row.names = F)

tmp_gaf = lapply(tools,function(cur_tool){
    #cur_tool = "argot2"
    cur_min_th = min_fscore_th[tool==cur_tool]$min_th
    curr_gaf = read_gaf(cur_tool,cur_min_th,in_dir)
    onts_w_annots = max_fscore_th[tool==cur_tool]$ont
    
    tmp_out = lapply(onts_w_annots,function(cur_aspect){
        min_aspect_th = max_fscore_th[tool==cur_tool & ont == cur_aspect]$th
        cur_ont = ont_code[[cur_aspect]]
        tmp_gaf = curr_gaf[aspect == cur_ont & with >= min_aspect_th]
        return(tmp_gaf)
    })
    curr_filt_gaf = do.call(rbind,tmp_out)
    write_gaf(cur_tool,curr_filt_gaf)
})
###



















if(F){
pr = tmp_data[metric=="precision"]
rc = tmp_data[metric=="recall"]$value
pr_rc = cbind(pr,rc)
colnames(pr_rc)[3] = "pr"

pr_rc$pr[pr_rc$pr<0] = 0
pr_rc$rc[pr_rc$rc<0] = 0


pr_rc_avg = pr_rc[,list(avg_pr=mean(pr),avg_rc=mean(rc)),by=list(th,ont)]
pr_rc_avg
pr_rc_avg
pr_rc_avg_melt = melt(pr_rc_avg,id.vars = c("th","ont"))
pr_rc_avg_melt


p = ggplot(pr_rc_avg_melt,aes(x=th,y=value,color=variable))
#p = p + geom_bar(data=argot2_eval$th_fscore,aes(x=th,y=avg_fscore,fill=ont),stat="identity",color="white")
p = p + geom_line(stat="identity") + scale_fill_brewer(type="qual",palette=5)
#p = p + geom_line(aes(y=avg_rc),stat="identity")
p = p + facet_grid(ont~.)
p


argot2_eval$fscores[,list(count=sum(fscore>0)),by=list(th)][order(th)]

gramene_eval = eval_data("eval/gramene")
gramene_eval$th_fscore

iprs_eval = eval_data("eval/iprs")
warnings()
iprs_eval$th_fscore

argot2_eval$plot
gramene_eval$th_fscore

p = ggplot(pr_rc_avg,aes(x=avg_rc,y=avg_pr,color=ont))
p = p + geom_bar(data=argot2_eval$th_fscore,aes(x=th,y=avg_fscore,fill=ont),stat="identity",color="white")
p = p + geom_hline(data=gramene_eval$th_fscore,aes(yintercept=avg_fscore,color=ont),size=1)
#p = p + geom_line(stat="identity")
p = p + scale_fill_brewer(type="qual",palette=5)
p = p + facet_grid(ont~.)
p

argot2_eval$th_fscore[,list(max_fscore=max(avg_fscore),max_th=th[which.max(avg_fscore)]),by=list(ont)]

argot2_eval$th_fscore[,list(max_fscore=max(avg_fscore),max_th=th[which.max(avg_fscore)]),by=list(ont)]

tmp_merge = merge(argot2_eval$fscores[th==.5],gramene_eval$fscores,by = c("gene","ont"),suffixes = c(".argot2",".gramene"))
tmp_merge
par(mfrow=c(2,2))
hist(tmp_merge[fscore.argot2>0 ]$fscore.argot2)
hist(tmp_merge$fscore.argot2)
hist(tmp_merge[fscore.gramene > 0]$fscore.gramene)
hist(tmp_merge$fscore.gramene)

tmp_merge[fscore.argot2==0 & fscore.gramene>0]

argot2_eval$fscores[,list(count=sum(fscore>0)),by=list(th)][order(th)]
gramene_eval$fscores[,list(count=sum(fscore>0))]
}