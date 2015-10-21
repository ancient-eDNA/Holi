#!/bin/bash
#$ -cwd 
#$ -l ram.c=7.5G,h_rt=12:00:00,high.c
#$ -pe pe_slots 8

module load bbtools
module load jgibio

$HOME/dev/copenhagen_moat/bin/cleanall.py \
--workdir $BSCRATCH/copenhagen/clean20151019-2 \
--datadir $BSCRATCH/copenhagen/raw \
--logfile $BSCRATCH/copenhagen/clean20151019-2/process.log


