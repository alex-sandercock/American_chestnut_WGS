#!/usr/bin/bash


####### job customization
#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH -t 12:00:00
####### end of job customization
#MAF filter 1/2n, so 1/(2*356) = 0.001404
#removing indels
#removing multiallelic sites
#Removing any sites with greater than 10% missing genotypes
#removing all individuals with greater than 10% missing data and removing hybrids from the admixture analysis
bcftools view American_chestnut_WGS_384_samples_filtered_remove_fail.vcf.gz \
	--threads 125 \
	--min-af 0.002:minor \
	--exclude-types indels \
	--max-alleles 2 \
	-e 'F_MISSING > 0.1' \
	--samples-file ^missing_hybrid_dentata.txt \
	-o American_chestnut_356_snps_only_filtered_remove_fail_miss_0.9_maf_0.002.vcf.gz