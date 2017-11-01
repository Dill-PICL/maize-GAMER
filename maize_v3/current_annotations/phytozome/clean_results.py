#!/usr/bin/env python
import sys, re, csv
import pprint as pp
import pandas as pd
import argparse
from datetime import date
from go_utils import gaf, obo
import timeit


parser = argparse.ArgumentParser(description='Convert the RBH output to to gaf files')
parser.add_argument("-i","--input", help="Input file with RBH GO output", required=True)
parser.add_argument("-o","--obo", help="OBO file from Gene Ontology", required=True)
parser.add_argument("-g","--gaf", help="output gaf file to store the value", required=True)
args = parser.parse_args()


def print_elasped(start_time):
    elapsed = timeit.default_timer() - start_time
    sys.stderr.write("Time taken - %s\n" % elapsed)
    return(timeit.default_timer())
#num_cores = int(args.num_threads)
start_time = timeit.default_timer()
sys.stderr.write("Importing the GO obo file\n")
input_obo = obo()
input_obo.read_file(args.obo)

start_time = print_elasped(start_time)

sys.stderr.write("Converting the obo to get the aspects for all GO terms\n")

aspects = {"biological_process":"P","molecular_function":"F","cellular_component":"C"}
go_aspect = {term['id']:aspects[term['namespace']] for term in input_obo.terms}

start_time = print_elasped(start_time)

sys.stderr.write("Reading Phytozome Data\n")
df = pd.read_csv(args.input,index_col=None,sep="\t",header=0,skiprows=1)
df.columns = ["pacId","locusName","transcriptName","peptideName","Pfam","Panther","KOG","KEGG/ec","KO","GO","Best-hit-arabi-name","arabi-symbol","arabi-defline"]
df = df[df["GO"].isnull() == False]
tmp_df = df.apply(lambda row: {"gene":row["locusName"],"go":row["GO"].split(",")},axis=1)

out_df = pd.DataFrame()
for f in tmp_df:
    f_df = pd.DataFrame.from_dict(f)
    out_df = out_df.append(f_df,ignore_index=True)
out_df["go"] = out_df["go"].replace({r'^GO\:':""},regex=True)

start_time = print_elasped(start_time)
in_gaf = gaf()

sys.stderr.write("Converting Pannzer results into a GAF\n")
in_gaf.init_annotations(out_df)
in_gaf.add_aspect(input_obo)
in_gaf.add_col_all("db","maize-GAMER")
in_gaf.add_col_all("qualifier","")
in_gaf.add_col_all("db_reference","MG:0000")
in_gaf.add_col_all("evidence_code","IEA")
in_gaf.add_col_all("with","0")
in_gaf.add_col_all("db_object_name","")
in_gaf.add_col_all("db_object_synonym","")
in_gaf.add_col_all("db_object_type","protein")
in_gaf.add_col_all("taxon","taxon:4577")
d = date.today()
in_gaf.add_col_all("date",d.strftime("%m%d%Y"))
in_gaf.add_col_all("assigned_by","Phytozome")
in_gaf.add_col_all("annotation_extension","")
in_gaf.add_col_all("gene_product_form_id","")
in_gaf.reorder_cols()

#tmp_fields = list(in_gaf.gaf_2_x_fields)

'''

# def add_to_gaf(row):
#     row_dict = row
#     aspect = ""
#     if row_dict["go"] in go_aspect:
#         aspect = go_aspect[row_dict["go"]]
#     else:
#         aspect = "N"
#     tmp_annot_data = ["Maize-GAME",row_dict["gene"],row_dict["gene"],"",row_dict["go"],"MG:0000","IEA",str(row_dict["score"]),aspect,"","","protein","taxon:4577","20161105","FANN-GO","",""]
#     tmp_annot = dict(zip(in_gaf.gaf_2_x_fields,tmp_annot_data))
#     in_gaf.add_annotation(tmp_annot)
#
# df.apply(add_to_gaf,axis=1)

# for row in df.iterrows():
#     #sys.stderr.write("%s\n" % (row[0]+1))
#     row_dict = row[1]
#     aspect = ""
#     if row_dict["go"] in go_aspect:
#         aspect = go_aspect[row_dict["go"]]
#     else:
#         aspect = "N"
#     tmp_annot_data = ["Maize-GAME",row_dict["gene"],row_dict["gene"],"",row_dict["go"],"MG:0000","IEA",str(row_dict["score"]),aspect,"","","protein","taxon:4577","20161105","FANN-GO","",""]
#     tmp_annot = dict(zip(in_gaf.gaf_2_x_fields,tmp_annot_data))
#     in_gaf.add_annotation(tmp_annot)
#     if (row[0]+1) % 100 == 0:
#         sys.stderr.write("Processed %s lines\n" % (row[0]+1))
in_gaf.annotations["with"] = pd.to_numeric(in_gaf.annotations["with"])

'''

start_time = print_elasped(start_time)
sys.stderr.write("Starting to write output files\n")

'''
for i in xrange(0,100,5):
    th = float(i)/100
    sys.stderr.write("Processing threshold - %s\n" % (th))
    #tmp_df = gaf_df[gaf_df["with"]>=th]
    outfile_th = args.gaf.split(".")
    outfile_th[0] = outfile_th[0]+"-%s" % (th)
    outfile_th = ".".join(outfile_th)
    in_gaf.write_gaf(outfile_th,"with",th)
'''
in_gaf.write_gaf(args.gaf)
start_time = print_elasped(start_time)
sys.stderr.write("Process is completed\n")
