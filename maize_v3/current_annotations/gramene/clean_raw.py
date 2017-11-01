#!/usr/bin/env python

import argparse

parser = argparse.ArgumentParser(description='Filter the gramene and fix it for evaluatijng with AIGO')
parser.add_argument("-i","--input", help="All Genes in the organism as a list", required=True)
parser.add_argument("-o", "--output", help="output file basename", required=True)
args = parser.parse_args()

#importing common packages
import sys, re, os
import pandas as pd
import numpy as np
import pprint as pp

#Importing custom packages
from go_utils import gaf

in_gaf = gaf()
in_gaf.read_gaf(args.input)

def clean_annotations(x):
    if x['db_object_symbol'] == '':
        x['db_object_symbol'] = str(x['db_object_id'])
    x['taxon'] = "taxon:%s" % x['taxon']
    return(x)

in_gaf.annotations = in_gaf.annotations.apply(clean_annotations,axis=1)
in_gaf.write_gaf(args.output)

