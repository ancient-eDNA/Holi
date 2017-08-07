library("DESeq2")
library("ggplot2")
library("genefilter")
library("reshape")
setwd("~/Documents/copenhagen")

## Prepare data ##

# Read in data
designData <- read.table(file ="data/processed/metadata.txt", sep="\t", header=T)
data <- read.table(file ="data/processed/all_counts_clean.txt", sep="\t", header=T)

# select data rows only
data.only<- data[,4:length(data)]

# Convert to matrix
cdmat <- as.matrix(data.only)

# make the 3 time periods factors
designData$period<- factor(designData$period)


## DESeq2 analysis ##

# create DESeq data object using the three time periods as factors period 3 and 4 are combined since 4 only has one sample
cds <- DESeqDataSetFromMatrix(countData = cdmat, colData = designData , ~ period, tidy = FALSE)
rownames(cds)<-data$number

# Scale the data by estimating size fators using the median ratio method from: 
# Simon Anders, Wolfgang Huber: Differential expression analysis for sequence count data. Genome Biology 2010, 11:106.
 cds = estimateSizeFactors( cds, type="ratio", locfunc = stats::median )
# Alternatively shorth can be used instead of median, this is may give better point estimates for data with many zeros
# cds = estimateSizeFactors( cds, type="ratio", locfunc = genefilter::shorth)

# Return the scaled counts from the prevous step 
ncounts<-counts(cds, normalized=TRUE)

# Estimate Dispersion by fitting the formula dispersion = asymptDisp + extraPois / mean  with a robust gamma-family GLM.
cds = estimateDispersions( cds )

## Estimating Interquartile range from the data for the data using Poisson and Negative binomial distributions##

# Function to refurn a critical value for a particular probability quantile.
meanconfint <- function(mu, theta, p){
    # note that qnbinom takes alpha as the dispersion parameter which is the inverse of theta reported by DESeq2
    criticalvalue = qnbinom(p = c(p), mu = mu , size=1/theta ) 
  return(criticalvalue)
}

poissonconfint <- function(mu, p){
  criticalvalue = qpois(p = c(p), lambda= mu  )
  return(criticalvalue)
}


## Create a long dataframe merging data together
 
# Transform normalized count data into a long dataframe
rs<- melt(ncounts)

#Add names to columns
names(rs)<-c("org","Sample", "pseudocount")

# extract dispersion estimates from cds object
disp <- data.frame(rownames(cds),rowData(cds)[,"dispersion"],rowData(cds)[,"dispFit"])
names(disp)<- c("org","dispersion","dispFit")

#merge the dispesion estimates into the data frame
rs2<-merge(rs,disp, by.x="org", by.y="org")

# select relevant metadata (year, depth, period) and add to the dataframe
dds<-designData[,c(1,2,5)]
rs3<-merge(rs2,dds, by.x="Sample",by.y="Sample")

# add taxonomy descriptions to the dataframe
rs35<-merge(rs3,data[,c(1,2,3)], by.x="org",by.y="number")


#Create a dataframe with the total number of reads per organism and merge with long dataframe
rowcountsdf<-data.frame(data$number, rowSums(data.only))
names(rowcountsdf)<-c("org","totalreads")
rs4<-merge(rs35,rowcountsdf,by.x="org",by.y="org")

# reorder the dataframe
rs4 <- rs4[,c(1,8,9,2,6,7,3,4,5,10)]

#Estimate the Interquartile ranges, adding them to the dataframe

rs4$ci.25<-meanconfint(mu=rs4$pseudocount,theta=rs4$dispersion, p = 0.25)
rs4$ci.75<-meanconfint(mu=rs4$pseudocount,theta=rs4$dispersion, p = 0.75)
# rs4$ci_fit.25<-meanconfint(mu=rs4$pseudocount,theta=rs4$dispFit, p = 0.25)
# rs4$ci_fit.75<-meanconfint(mu=rs4$pseudocount,theta=rs4$dispFit, p = 0.75)
rs4$pois.25<-poissonconfint(mu=rs4$pseudocount, p = 0.25)
rs4$pois.75<-poissonconfint(mu=rs4$pseudocount, p = 0.75)

# write the dataframe to a file
write.table(x=rs4, file="countsandCI.txt", sep="\t", col.names=T, row.names=F)

# Write the size factors to a file
write.table(data.frame(sizeFactors(cds)), file="sizefactors.txt")

# Define a fucntion to plot normalized abundances for all taxa in one pdf
plotgraphs <-function(dataframe, file){
  pdf(file, paper='letter', onefile=TRUE)
  for(i in unique(dataframe$org)){
    dftemp <- dataframe[dataframe$org == i,]
    p <- ggplot(data=dftemp, aes(Year,pseudocount)) +
      geom_point() +
      geom_line(color="grey70") +
      geom_errorbar(color="lightblue", aes(ymax=ci.75, ymin=ci.25)) +
      geom_errorbar(color="mediumblue", aes(ymax=pois.75, ymin=pois.25)) + 
      ggtitle(dftemp$shortname[1])
   print(p)
  }
  dev.off()
}

# Plot to check results
plotgraphs(dataframe=rs4, file="urbanizationplots10.pdf")




## Scaling of cholera specific data

# read counts from detailed mapping to many Vibrio genomes
choleradata <- read.table(file ="data/choleraonly.csv", sep=",", header=T)

# Scale counts using median ratio method calulated previously
choleradata$ncounts <- choleradata$Vibrio.cholerae / choleradata$Size.factors.CDS
# order counts by year
choleradata<-choleradata[order(choleradata$Year),]
# merge with dispersion estimates for the Genus Vibrio from the larger dataset
rs4vibrio<-rs4[rs4$shortname=="1766_Vibrio",c(4,8,9)]
choleradata<- merge(choleradata, rs4vibrio, by.x="Sample.ID", by.y="Sample")
# Calulate Negitive binomial IQR and estimate the propotion of the variance coming from count error with the Poisson
choleradata$ci.25<-meanconfint(mu=choleradata$ncounts,theta=choleradata$dispersion, p = 0.25)
choleradata$ci.75<-meanconfint(mu=choleradata$ncounts,theta=choleradata$dispersion, p = 0.75)
choleradata$pois.25<-poissonconfint(mu=choleradata$ncounts, p = 0.25)
choleradata$pois.75<-poissonconfint(mu=choleradata$ncounts, p = 0.75)

# plot to check results
ggplot(data=choleradata, aes(y=ncounts, x=Year)) + 
  geom_point() +
  geom_line(color="grey70") + 
  geom_errorbar(aes(ymin=ci.25, ymax=ci.75), color="lightblue") +
  geom_errorbar(aes(ymin=pois.25, ymax=pois.75), color="mediumblue")

# write results to a table
write.table(choleradata, file="choleraDataWithCIs.txt", sep="\t")