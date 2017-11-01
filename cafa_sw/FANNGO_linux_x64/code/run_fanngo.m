echo off all
cd code
[Headers, Sequences] = fastaread('../Zm.AGPv4.pep.filt.fa')
PRED=MAIN(Sequences)
Headers = transpose(Headers)
Headers = regexprep(Headers, ' .*', '')
tbnames = horzcat('gene_id',PRED.accessions)
tbnames = strrep(tbnames,':','_')
scores = num2cell(PRED.scores)
all_scores = horzcat(Headers,scores)
all_scores = cell2table(all_scores)
all_scores.Properties.VariableNames = tbnames
writetable(all_scores,'../scores.txt','Delimiter','\t')
