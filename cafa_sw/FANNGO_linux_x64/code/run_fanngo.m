echo off all
cd code
[Headers, Sequences] = fastaread('../maize_v3.longest.aa.fa')
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
