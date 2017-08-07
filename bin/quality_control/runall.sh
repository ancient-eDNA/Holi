#!/bin/bash
# runall.sh a script to download and clean the copenhagen moat data
# Usage download.sh <workingdir> <url>

# Working dir structure
# -WD
#   |-raw
#		|-paired_controls
#		|-paired_samples
#		|-unpaired_controls
#		|-unaired_samples
#	|-sampled
#		|-paired_controls
#		|-paired_samples
#		|-unpaired_controls
#		|-unaired_samples
#	|-samplesfinal
#		|-<all sample files>

# Variables
url="$2"
workingdir="$1"
wd="`pwd` $workingdir"
depth=40000
bindir=""

# Run settings
download="False"
sampled="True"
submit="True"

## Downloading data
if [ "$download" = "True" ]; then
	cd $wd
	mkdir raw
	cd raw
	wget -rc "$url"
fi
mv  ftp.dna.ku.dk/sent_to_JGI_oct1025/* .
rm -r ftp.dna.ku.dk

#check data:
~/dev/copenhagen_moat/bin/shacheck.py paired_controls/ ~/dev/copenhagen_moat/data/metadata_final.txt >sha1check.txt
~/dev/copenhagen_moat/bin/shacheck.py unpaired_controls/ ~/dev/copenhagen_moat/data/metadata_final.txt >>sha1check.txt
~/dev/copenhagen_moat/bin/shacheck.py paired_samples/ ~/dev/copenhagen_moat/data/metadata_final.txt >>sha1check.txt
~/dev/copenhagen_moat/bin/shacheck.py unpaired_samples/ ~/dev/copenhagen_moat/data/metadata_final.txt >>sha1check.txt


## sampling data
if [ "$sampled" = "True" ]; then
	cd $wd
	mkdir sampled
	cd sampled
	mkdir paired_controls
	mkdir paired_samples
	mkdir unpaired_controls
	mkdir unaired_samples
	for f in  ../raw/paired_controls/*
	do
		zcat "$f" | head -n $depth  | gzip > paired_controls/`basename "$f"`
	done
	for f in  ../raw/unpaired_controls/*
	do
		zcat "$f" | head -n $depth  | gzip > unpaired_controls/`basename "$f"`
	done
	for f in  ../raw/paired_samples/*
	do
		zcat "$f" | head -n $depth  | gzip > paired_samples/`basename "$f"`
	done
	for f in  ../raw/unpaired_samples/*
	do
		zcat "$f" | head -n $depth  | gzip > unpaired_samples/`basename "$f"`
	done
fi

if [ "$submit" = "True" ]; then
	qsub ~/dev/copenhagen_moat/bin/cleansub.sh
fi

