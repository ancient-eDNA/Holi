#!/usr/bin/env python
#checksha1.py filedir metadata_final.txt 

import sys
import os
import re
import subprocess

path = os.path.abspath(sys.argv[1])
ma = []
nm = [] 
nf = []
with open(sys.argv[2], 'r') as infile:
    for file in os.listdir(path):
    	file = file.strip()
        fp = os.path.join(path,file)
        p1 = subprocess.Popen(["openssl", "sha1", fp], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        shadata, err = p1.communicate()
        shadata = shadata.split("=")[1].strip()
        for line in infile:
            if re.match("\#", line):
                continue
            ln = line.strip().split()
            filename = ln[2].strip()
            sha = ln[16].strip()
            if file == filename:
                if shadata == sha:
                    print(file + ": matches")
                    ma.append(file)
                    infile.seek(0, 0)
                    break
                else:
                    print("ERROR: " + file + " does not match its sha1 hash. \n The hash of the file was " + shadata + " but hash in the list was " + sha)
                    nm.append(file)
                    infile.seek(0, 0)
                    break
        else:
            print("ERROR: " + file + " could not be found")
            nf.append(file)
            infile.seek(0, 0)
print("")
print("%d files matched" % len(ma))
print("%d files had different sha1 hash values" % len(nm))
if len(nm) > 0:
    for i in nm:
        print(i)
print("%d files were not found in the hash table list" % len(nf))
if len(nf) > 0:
    for j in nf:
        print(j)
print("____________________")
                 
        


