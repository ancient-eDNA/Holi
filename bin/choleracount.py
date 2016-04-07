#!/usr/bin/env python

import argparse
import sys
import os.path
import numpy as np
import re
import pandas


parser = argparse.ArgumentParser(description='Parse bbmap mapping files and  crate taxa sample counts')
parser.add_argument('--indir', help='directory containing the read files')
parser.add_argument('--outfile', help='a file with the table of counts and categories')
args = parser.parse_args()


indir = os.path.abspath(args.indir)
outfile = os.path.abspath(args.outfile)

datadict={} # dict of the form [taxid][sample]:count
for files in os.listdir(indir):
    file = os.path.join(indir,files)
    sample = os.path.basename(file).split('.')[0]
    if not sample in datadict:
    	datadict[sample] = {}
    with open(file, "r") as f:
        for line in f:
            if not line.startswith("#"):
                ln = line.strip().split("\t")
                unambiguousReads = int(ln[5])
                ambiguousReads = int(ln[6])
                allreads = unambiguousReads + ambiguousReads
                taxid = ln[0].split(",")[1].split("=")[1]
#                 print(taxid)
#                 print(sample)
#                 print(unambiguousReads)
#                 print(ambiguousReads)
                if not taxid in datadict[sample]:
                    datadict[sample][taxid] = allreads
                else:
                    datadict[sample][taxid] += allreads

df = pandas.DataFrame.from_dict(datadict)
df.sort()
df.to_csv(outfile)
print(df.sum(axis=0))
print(df.sum(axis=1).sort())
    
     