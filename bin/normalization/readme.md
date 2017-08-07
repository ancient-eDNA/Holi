# README

This directory contains data from an experiment mapping reads to a reference
database of reference taxa at 100% identity.

## Files:
1. all_counts_clean.txt - A tab delimited file containing the raw mapped counts
 for each samples
    * column 1: number - a row number
    * column 2: shortname - a unique short name combineing the row number and
 the lowest taxonomic identifier
    * column 3: taxonomy - the full, semicolon separated taxonomy from the program Megan
    * all remaining columns - raw read counts for each sample
2. all_counts_normalized.txt - a tab delimited file with counts normalized using
 the median ratio method of DESeq2. columns are the same as for the non-normalized data.
3. dispersionests.txt -A tab delimited file containing the dispersion estimates
 generated from grouping the data into 4 externally derived time points.
 Note that this split may not be supported by the data and we may need to take a time series approach
4. metadata.txt - a tab delimited file linking each library to its identifiers and the amount of data that mapped. 
5. DESeq_normalization_dispersion_estimation.R - a script to import data into DESeq and run its transformations and estimates.

Information on DESeq2:

[The vignette on DESeq2](https://www.bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html)

[The paper on DESeq2](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-014-0550-8)

[The reference manual](https://www.bioconductor.org/packages/release/bioc/manuals/DESeq2/man/DESeq2.pdf)