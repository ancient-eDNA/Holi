#!/usr/env/python
import os
import sys
directory = "/global/projectb/scratch/arrivers/copenhagen20160329/krakenout"
cc = 0
for file in os.listdir(directory):
    sys.stderr.write(Classified " + str(cc) + " reads\n")
	sys.stderr.write("Opening file "+ file +"\n")
	with open(file, 'r') as f:
		for line in f:
			ln = line.strip().split('\t')
		 	if ln[0] == "C":
		 		cc = cc + 1
		 		sys.stdout.write(file + "\t" + line)
		 		
		 		 