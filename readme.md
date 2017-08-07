# Scripts from work done at the Joint Genome Institute to process sequencing data in the paper:
Tracing past ambient air pollution and its consequences on human health. Submitted 7/31/2017.Pedersen, M.W. et al.

This directory has:
* data - a directory containing sequencing metadata
* bin/quality_control - a directory containing the scripst used to retrieve and runn quality control precedures on the sequence data
* bin/vibrio_mapping - scripts to retrieve vibrio genomes and mapp all reads to the vibrio genomes, then tally the results
* bin/normalization - Scripts used to normalize count data, estimate the variance and add inter-quartile range estimates for the count data 

The data are from different sequencing runs using paired and unpaired illumina libraries.  
A number of control libraries (sample blanks, library blanks, etc.) were sequenced. Reads  
from these libraries are used to decontaminate sample data in conjunction with the standard  
decontamination files.

The data quality control and mapping was done using using the [bbtools](http://jgi.doe.gov/data-and-tools/bbtools/) 
software suite.  Vibrio data was retrieved using [Reftree](https://bitbucket.org/berkeleylab/jgi_reftree). The Normalization and variance estimation was done using the R package [DESeq2](https://bioconductor.org/packages/devel/bioc/html/DESeq2.html) 
