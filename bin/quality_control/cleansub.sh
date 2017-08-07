#!/bin/bash
#$ -cwd 
#$ -l ram.c=5G,h_rt=12:00:00
#$ -pe pe_slots 16

module load bbtools
module load jgibio

$HOME/dev/copenhagen_moat/bin/cleanall.py \
--workdir $BSCRATCH/copenhagen/clean20151025 \
--datadir $BSCRATCH/copenhagen/raw \
--logfile $BSCRATCH/copenhagen/clean20151025/process.log


