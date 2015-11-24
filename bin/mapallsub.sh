#!/bin/bash
#$ -cwd
#$ -l ram.c=7.5G,h_rt=12:00:00
#$ -pe pe_slots 16

module load bbtools
module load pigz
. reftree.env.sh

$HOME/dev/copenhagen_moat/bin/mapall.sh /global/projectb/scratch/arrivers/copenhagen/clean20151025 /global/projectb/scratch/arrivers/copenhagen/clean20151025/samplesfinal

