#!/bin/bash
#mapall.sh <workingdir> <datadir>

module load bbtools
module load pigz
. reftree.env.sh

# Variables
workingdir="$1"
datadir="$2"
wd=`readlink -f "$workingdir"`



# Run settings
reftree="False"
findcandidates="False"
map="True"

cd $wd
mkdir -p $wd/mapping
cd $wd/mapping

if [ "$reftree" = "True" ]; then
	#collect all Vibrio genomes from RefSeq using the program RefTree https://bitbucket.org/berkeleylab/jgi_reftree
	reftree.pl  --db genomic --subtree 662 > Vibrio.fna
	#collect all Vibrio cholerae genomes from RefSeq using the program RefTree
	reftree.pl  --db genomic --subtree 666 > Vcholerae.fna
	#count taxa represented
	echo "Vibrio cholerae strains:"
	grep ">" Vcholerae.fna | cut -f 2 -d ","  | sort | uniq| wc -l
	echo "Vibrio strains:"
	grep ">" Vibrio.fna | cut -f 2 -d ","  | sort | uniq| wc -l

fi


## use bbduk to find reads with at least 1 25-mer that matches one of ~650 genomes from bacteria in the genus Vibrio
if [ "$findcandidates" = "True" ]; then
	mkdir -p "$wd"/mapping/vibrio_candidate_reads
	mkdir -p "$wd"/mapping/vibrio_candidate_reads/stats
	for f in $datadir/*.fa.gz 
	do
		echo "Running bbduk.sh on file $f"
		bname=`basename $f .fa.gz`
		echo
		bbduk.sh in="$f" ref="$wd/mapping/Vibrio.fna" outm="$wd"/mapping/vibrio_candidate_reads/"$bname".fa.gz k=25 stats=$"$wd"/mapping/vibrio_candidate_reads/stats/"$bname".txt
	done
fi

## use bbmap to find reads that map to one of ~200 Vibrio cholera genomes with > 95% \
	# identity. Reads are mapped all bast-matching reference configs
if [ "$map" = "True" ]; then
	mkdir -p "$wd"/mapping/vibrio_cholerae_map
	mkdir -p "$wd"/mapping/vibrio_cholerae_map/hist
	mkdir -p "$wd"/mapping/vibrio_cholerae_map/sam
	mkdir -p "$wd"/mapping/vibrio_cholerae_map/scafstats
	echo "Indexing Vibrio cholerae genomes"
	bbmap.sh ref="$wd"/mapping/Vcholerae.fna \
		pigz=t \
		unpigz=t \
		usejni=t \
		
	for g in "$wd"/mapping/vibrio_candidate_reads/*fa.gz
	do
		echo "Running bbmap.sh on file $g"
		bname=`basename $g .fa.gz`
		bbmap.sh in="$g" \
		scafstats=$"$wd"/mapping/vibrio_cholerae_map/scafstats/"$bname".txt \
		interleaved=false \
		minid=0.95 \
		ambiguous=all \
		secondarycov=t \
		maxindel=10 \
		pigz=t \
		unpigz=t \
		usejni=t \
		out="$wd"/mapping/vibrio_cholerae_map/sam/"$bname".sam
		idhist="$wd"/mapping/vibrio_cholerae_map/hist/"$bname".txt
		 
	done
fi
