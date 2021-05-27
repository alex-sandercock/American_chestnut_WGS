#!/usr/bin/bash

#Use to subsample a vcf file of snp data
#-n equals the number of snps that you want to retain
#jvarkit is the software and Jason placed it in my group folder.

module load jdk/1.8.0
java -jar /jvarkit/dist/downsamplevcf.jar input.vcf -n 100000 > output.vcf

##The above script tends to only sample the final chromosome (12). The below script will randomly sample throughout the vcf file.
cd $WORK/Pure_American_Analysis/VCFs

$HOME/bin/bcftools view --header-only American_chestnut_WGS_384_samples_filtered_remove_fail_miss_0.9.vcf.recode.vcf > subsample_384_100k.vcf
$HOME/bin/bcftools view --no-header American_chestnut_WGS_384_samples_filtered_remove_fail_miss_0.9.vcf.recode.vcf | awk '{printf("%f\t%s\n",rand(),$0);}' | sort -t $'\t' -k1,1g | cut -f2-  | head -n 100000 >>  subsample_384_100k.vcf

##Shuf has been recommended as long as each snp is on a separate line.

#shuf -n 100000 American_chestnut_WGS_384_samples_filtered_remove_fail_miss_0.9_100k_SNPs.recode.vcf > subset_shuf.vcf

#Can also use bcftools to subsample. the number after -r is the percent of the original vcf file SNPS that you want in the new file

bcftools view cichlid_full.vcf.gz | vcfrandomsample -r 0.012 > cichlid_subset.vcf