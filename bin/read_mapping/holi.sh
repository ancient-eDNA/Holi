#!/usr/bin/env bash
###### Holi ############

#Dependencies this pipeline has been setup in a Unix environment and have not been tested on other operating systems (it expects basic utilities such as sort, bzip2 and like)
    #fastq-tools https://github.com/dcjones/fastq-tools/
    #String Genome Assembly (SGA) - https://github.com/jts/sga
    #Bowtie2 - https://github.com/BenLangmead/bowtie2
    #Samtools - https://github.com/samtools/samtools
    #eventually MEGAN5 - MEtaGenomeANalyzer or like http://ab.inf.uni-tuebingen.de/software/megan5/ (desktop operated)


for infile in $(pwd)/*.fq
do    
bname=$(basename $infile)
echo Processing file= $bname
bname2=$(echo $bname | sed 's/.fq*/_holi/')
basepath=$(pwd)/
basefolder=$basepath
echo in folder= $basepath
mkdir $basepath$bname2  
cd $basepath$bname2
pwd

echo Step 1. Removing poly A tails
fastq-grep -v "AAAAA$" ../$bname > kmer_$bname
echo Step 2. Removing reverse complemented A tails
fastq-grep -v "^TTTTT" kmer_$bname > kmer2_$bname
bzip2 kmer_$bname &
echo Step 3. Removing rememnants adapter sequence 1 = AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
fastq-grep -v "AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC" kmer2_$bname > adap1_kmer2_$bname
bzip2 kmer2_$bname &
echo Step 4. Removing remnants adapter sequence 2 = ATCTCGTATGCCGTCTTCTGCTTG
fastq-grep -v "ATCTCGTATGCCGTCTTCTGCTTG" adap1_kmer2_$bname > adap2_kmer2_$bname
bzip2 adap1_kmer2_$bname &
echo Step 5. Counting sequences matching vector tracer 'ATTAACCCTCACTAAAGGGACTAGTCCTGCAGGTTTAAACGAATTCGCCCTTAAGGGCGAATTCGCGGCCGCTAAATTCAATTCGCCCTATAGTGAGTCGTATTA' =
fastq-grep -c "ATTAACCCTCACTAAAGGGACTAGTCCTGCAGGTTTAAACGAATTCGCCCTTAAGGGCGAATTCGCGGCCGCTAAATTCAATTCGCCCTATAGTGAGTCGTATTA" adap2_kmer2_$bname


echo Step 6. sga preprocessing
nice -n 5 sga preprocess --dust-threshold=1 -m 30 adap2_kmer2_$bname -o adap2_kmer2_$bname.pp.fq
bzip2 adap2_kmer2_$bname
echo Step 7. sga index
nice -n 5 sga index --algorithm=ropebwt --threads=12 adap2_kmer2_$bname.pp.fq
echo Step 8. sga filter
nice -n 5 sga filter --threads=12  --no-kmer-check adap2_kmer2_$bname.pp.fq -o adap2_kmer2_$bname.pp.rmdup.fq
out=$bname


echo Step 9. Calculating read length distribution and outputting file
cat adap2_kmer2_$bname.pp.rmdup.fq | awk '{if(NR%4==2) print length($1)}' | sort -n | uniq -c > adap2_kmer2_$bname.pp.rmdup.fq.read_length.txt

echo Step 10. mapping against db
for DB in /path_to_database/nt_db/nt.? /path_to_database/nt_db/database/nt_db/nt.10
do
echo Mapping $bname2 against $DB
cd $basepath$bname2
time nice -n 5 bowtie2 --threads 20 -k 50 -x $DB -U adap2_kmer2_$bname.pp.rmdup.fq --no-unal > adap2_kmer2_$bname.pp.rmdup.fq.$(basename $DB).sam 2> $bname.bow2.$(basename $DB).log.txt
done

echo Step 11. merging and adding $file

cd $basepath$bname2
for file in *.nt.*.sam
do
samtools view -S $basepath$bname2/$file >> $basepath$bname2/merged.outfile.sam
sort -T /your_path/TMP -k 1 $basepath$bname2/merged.outfile.sam > $basepath$bname2/adap2_kmer2_$bname.pp.rmdup.nt.merged.outfile.sorted.sam
bzip2 adap2_kmer2_$bname.pp.rmdup.fq.nt.?.sam
cd ..
done
done
