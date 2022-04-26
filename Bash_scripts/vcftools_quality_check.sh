#!/usr/bin/bash

#Scripts from https://speciationgenomics.github.io/filtering_vcfs/

# move to your vcf directory
cd ~/vcf
# copy the data file from the data directory
cp /home/data/vcf/cichlid_full.vcf.gz* ./

#Check number of variants
#bcftools view -H cichlid_full.vcf.gz | wc -l

#VCF file subsetting
#bcftools view cichlid_full.vcf.gz | vcfrandomsample -r 0.012 > cichlid_subset.vcf

#make directory for results
mkdir ~/vcftools

#Declare variables
SUBSET_VCF=~/vcf/cichlid_subset.vcf.gz
OUT=~/vcftools/cichlid_subset

#Calculate allele frequency
vcftools --gzvcf $SUBSET_VCF --freq2 --out $OUT --max-alleles 2

#Calculate mean depth of coverage per individual
vcftools --gzvcf $SUBSET_VCF --depth --out $OUT

#Calculate mean depth per site
vcftools --gzvcf $SUBSET_VCF --site-mean-depth --out $OUT

#Calculate site quality
vcftools --gzvcf $SUBSET_VCF --site-quality --out $OUT

#Calculate proportion of missing data per individual
vcftools --gzvcf $SUBSET_VCF --missing-indv --out $OUT

#Calculate proportion of missing data per site
vcftools --gzvcf $SUBSET_VCF --missing-site --out $OUT

#Calculate heterozygosity and inbreeding coefficient per individual
vcftools --gzvcf $SUBSET_VCF --het --out $OUT

##As a side note, admixture calculates HWE or Fst between the clusters that it identifies

##End of stats, now send files to R for final analysis and visualization.
