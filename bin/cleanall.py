#!/usr/bin/env python

import os
import sys
import argparse
import subprocess
import signal
import re

 

parser = argparse.ArgumentParser(description=' cleanall.py: A script to run cleanup on the Copenhagen moat data')
parser.add_argument('--workdir', help="the working directory", required=True)
parser.add_argument('--datadir', help="the data directory", required=True) 
parser.add_argument('--logfile', help="the log file", default="log.txt") 
args = parser.parse_args()

def signal_term_handler(signal, frame):
    sys.stderr.write('cleanall.py was killed by a SIGTERM command')
    sys.exit(1)

signal.signal(signal.SIGTERM, signal_term_handler)


datadir = os.path.abspath(args.datadir)
workdir = os.path.abspath(args.workdir)

if not os.path.exists(workdir):
    os.makedirs(workdir)

log = open(args.logfile, 'w') # Open log file

# Unpaired control libraries
log.write("running QC on unpaired control libraries\n")
for file in os.listdir(os.path.join(datadir,"unpaired_controls")):
    outdir = os.path.join(workdir,"unpaired_controls",os.path.splitext(os.path.splitext(file)[0])[0])
    args1 = ["rqcfilter.sh", "in=" + os.path.join(datadir,"unpaired_controls",file), \
    "path=" + outdir, "trimfragadapter=t", "qtrim=r","trimq=0", "maxns=3", "maq=3", "minlen=25", "mlf=0.0", \
    "removehuman=f", "removedog=f", "removecat=f", "phix=t", "filterk=25", "forcetrimmod=0","barcodefilter=f"]
    p1 = subprocess.Popen(args1,stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    out, err = p1.communicate()
    log.write(out)
    log.write(err)

# Paired control libraries
log.write("running QC on paired control libraries\n")
log.flush()
for file in os.listdir(os.path.join(datadir,"paired_controls")):
    if re.search("R1", file):
        file2 = re.sub("R1", "R2",file) 
        outdir = os.path.join(workdir,"paired_controls",os.path.splitext(os.path.splitext(file)[0])[0])
        args1 = ["rqcfilter.sh", "in=" + os.path.join(datadir,"paired_controls",file), \
        "in2=" + os.path.join(datadir,"paired_controls",file2), \
        "path=" + outdir, \
        "trimfragadapter=t", "qtrim=r","trimq=0", "maxns=3", "maq=3", "minlen=25", "mlf=0.0", \
        "removehuman=f", "removedog=f", "removecat=f", "phix=t", "filterk=25", "forcetrimmod=0","barcodefilter=f"]
        p1 = subprocess.Popen(args1,stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        out, err = p1.communicate()
        log.write(out)
        log.write(err)      
        args2 = ["bbmerge.sh", "in=" + os.path.join(outdir,os.path.splitext(os.path.splitext(file)[0])[0] + ".anqdpt.fq.gz" ),\
        "out=" + os.path.join(outdir,os.path.splitext(os.path.splitext(file)[0])[0] + ".mergedandunmerged.fq.gz"),\
        "mix=t","usejni=t"]
        p2 = subprocess.Popen(args2,stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        out, err = p2.communicate()
        log.write(out)
        log.write(err)
        
# Combine control libraries
log.write("Combining control reads into a combined fasta file\n")
log.flush()
with open(os.path.join(workdir,"contaminants.fa"), 'a') as contam:
    for root, dirs, files in os.walk(os.path.join(workdir,"paired_controls")):
        for file in files:
            if file.endswith("mergedandunmerged.fq.gz"):
                p3= subprocess.Popen(["zcat", os.path.join(root, file)], stdout=subprocess.PIPE)
                p4= subprocess.Popen(["jgi_fastq_to_fasta","-","-"], stdin=p3.stdout, stdout=subprocess.PIPE) 
                p3.stdout.close()
                output = p4.communicate()[0]
                contam.write(output)
                
    for root, dirs, files in os.walk(os.path.join(workdir,"unpaired_controls")):
        for file in files:
            if file.endswith("anqdpt.fq.gz"):
                p3= subprocess.Popen(["zcat", os.path.join(root, file)], stdout=subprocess.PIPE)
                p4= subprocess.Popen(["jgi_fastq_to_fasta","-","-"], stdin=p3.stdout, stdout=subprocess.PIPE) 
                p3.stdout.close()
                output = p4.communicate()[0]
                contam.write(output)
contam.close()


# Unpaired sample libraries
log.write("running QC on unpaired sample libraries\n")
for file in os.listdir(os.path.join(datadir,"unpaired_samples")):
    outdir = os.path.join(workdir,"unpaired_samples",os.path.splitext(os.path.splitext(file)[0])[0])
    args1 = ["rqcfilter.sh", "in=" + os.path.join(datadir,"unpaired_samples",file), \
    "path=" + outdir, "trimfragadapter=t", "qtrim=r","trimq=0", "maxns=3", "maq=3", "minlen=25", "mlf=0.0", \
    "removehuman=f", "removedog=f", "removecat=f", "phix=t", "filterk=25", "forcetrimmod=0", \
    "barcodefilter=f", "ref="+ os.path.join(workdir,"contaminants.fa"), "filterhdist=0" ]
    p1 = subprocess.Popen(args1,stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    out, err = p1.communicate()
    log.write(out)
    log.write(err)
    log.flush()

# Paired sample libraries
log.write("running QC on paired sample libraries\n")
log.flush()
for file in os.listdir(os.path.join(datadir,"paired_samples")):
    if re.search("R1", file):
        file2 = re.sub("R1", "R2",file) 
        outdir = os.path.join(workdir,"paired_samples",os.path.splitext(os.path.splitext(file)[0])[0])
        args1 = ["rqcfilter.sh", "in=" + os.path.join(datadir,"paired_samples",file), \
        "in2=" + os.path.join(datadir,"paired_samples",file2), \
        "path=" + outdir, \
        "trimfragadapter=t", "qtrim=r","trimq=0", "maxns=3", "maq=3", "minlen=25", "mlf=0.0", \
        "removehuman=f", "removedog=f", "removecat=f", "phix=t", "filterk=25", "forcetrimmod=0", \
        "barcodefilter=f", "ref="+ os.path.join(workdir,"contaminants.fa"), "filterhdist=0" ]
        p1 = subprocess.Popen(args1,stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        out, err = p1.communicate()
        log.write(out)
        log.write(err)      
        args2 = ["bbmerge.sh", "in=" + os.path.join(outdir,os.path.splitext(os.path.splitext(file)[0])[0] + ".anqdpt.fq.gz" ),\
        "out=" + os.path.join(outdir,os.path.splitext(os.path.splitext(file)[0])[0] + ".all.fq.gz"),\
        "mix=t","usejni=t"]
        p2 = subprocess.Popen(args2,stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        out, err = p2.communicate()
        log.write(out)
        log.write(err)


# Convert sample reads to FASTA
log.write("Converting sample reads to reads FASTA and placing them in into the samplesfinal directory\n")
log.flush()
sampdir = os.path.join(workdir,"samplesfinal")
if not os.path.exists(sampdir):
    os.mkdir(sampdir)

for root, dirs, files in os.walk(os.path.join(workdir,"paired_samples")):
    for file in files:
        if file.endswith("all.fq.gz"):
			p3= subprocess.Popen(["zcat", os.path.join(root, file)], stdout=subprocess.PIPE)
			p4= subprocess.Popen(["jgi_fastq_to_fasta","-","-"], stdin=p3.stdout, stdout=subprocess.PIPE)
			p5= subprocess.Popen(["gzip", "-c"], stdin=p4.stdout, stdout=subprocess.PIPE)
			p3.stdout.close()
			p4.stdout.close()
			output = p5.communicate()[0]
			with open(os.path.join(sampdir,os.path.splitext(os.path.splitext(os.path.splitext(file)[0])[0])[0] + ".fa.gz"), 'wb') as fasta:
				fasta.write(output)
for root, dirs, files in os.walk(os.path.join(workdir,"unpaired_samples")):
    for file in files:
        if file.endswith("anqdpt.fq.gz"):
			p3= subprocess.Popen(["zcat", os.path.join(root, file)], stdout=subprocess.PIPE)
			p4= subprocess.Popen(["jgi_fastq_to_fasta","-","-"], stdin=p3.stdout, stdout=subprocess.PIPE)
			p5= subprocess.Popen(["gzip", "-c"], stdin=p4.stdout, stdout=subprocess.PIPE)
			p3.stdout.close()
			p4.stdout.close()
			output = p5.communicate()[0]
			with open(os.path.join(sampdir,os.path.splitext(os.path.splitext(os.path.splitext(file)[0])[0])[0] + ".fa.gz"), 'wb') as fasta:
				fasta.write(output)

log.close()

