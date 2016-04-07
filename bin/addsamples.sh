#!/bin/bash
module load bbtools
# addsamples.sh A script to add three additional samples to the Copenhagen moat dataset

datadir="/global/dna/projectdirs/MEP/oldcores/www/copenhagenmoat/data/clean20151025"

workingdir="/global/projectb/scratch/arrivers/copenhagen20160211/data"

#
for f in $workingdir/*
  do
	fname=$(basename $f .fq.gz)
  	mkdir clean/$fname
    rqcfilter.sh in=$f path=clean/$fname trimfragadapter=t qtrim=r trimq=0 maxns=3 \
    maq=3 minlen=25 mlf=0.0 removehuman=f removedog=f removecat=f phix=t filterk=25 \
    barcodefilter=f ref=$datadir/contaminants.fa.gz filterhdist=0
  done
  