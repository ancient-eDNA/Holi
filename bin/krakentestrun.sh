#!/bin/bash
#$ -cwd
#$ -l ram.c=15.5G,h_rt=01:00:00
#$ -pe pe_slots 16

# mkdir /global/projectb/scratch/arrivers/copenhagen20160329
# mkdir /global/projectb/scratch/arrivers/copenhagen20160329/samplesfinal
# cp  /global/dna/projectdirs/MEP/oldcores/www/copenhagenmoat/data/clean20151025/samplesfinal/* /global/projectb/scratch/arrivers/copenhagen20160329/samplesfinal

#subset the data for testing
# mkdir /global/projectb/scratch/arrivers/copenhagen20160329/samplessubset

#for file in /global/projectb/scratch/arrivers/copenhagen20160329/samplesfinal/*
#  do 
#    zcat $file | head -n 10000 | gzip > "/global/projectb/scratch/arrivers/copenhagen20160329/samplessubset/"$(basename "$file")
#  done


# Kraken analysis
. $HOME/lib/kraken/env.sh
DBNAME="/global/projectb/scratch/arrivers/krackendb/"

#test a subset of the data
#mkdir /global/projectb/scratch/arrivers/copenhagen20160329/krakenoutsubset

#for file in /global/projectb/scratch/arrivers/copenhagen20160329/samplesfinal/*
#  do 
#    zcat $file | head -n 10000 | gzip > "/global/projectb/scratch/arrivers/copenhagen20160329/samplessubset/"$(basename "$file")
#  done

FILENAME=`ls "/global/projectb/scratch/arrivers/copenhagen20160329/samplesfinal/" | head -n $SGE_TASK_ID | tail -n 1`
time kraken --preload  --db $DBNAME --threads 4  "/global/projectb/scratch/arrivers/copenhagen20160329/samplessubset/BH73_114_5.fa.gz" >  "/global/projectb/scratch/arrivers/copenhagen20160329/krakenoutsubset/BH73_115_5.txt"