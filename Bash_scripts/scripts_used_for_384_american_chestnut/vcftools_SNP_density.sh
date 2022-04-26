#!/usr/bin/bash

################## Access group and queue, use one or the other#######################

#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH -t 24:00:00
####### end of job customization

#$HOME/bin/vcftools --SNPdensity 50000 --gzvcf --keep south_pop.txt ../American_chestnut_356_snps_only_filtered_remove_fail_max_allele_2_miss_0.9_maf_0.002.vcf.gz --out SNP_density_of_South_Pop_Sites_in_American_chestnut_356_snps_only_filtered_remove_fail_max_allele_2_miss_0.9_maf_0.002.tsv

#$HOME/bin/vcftools --SNPdensity 50000 --gzvcf --keep central_pop.txt ../American_chestnut_356_snps_only_filtered_remove_fail_max_allele_2_miss_0.9_maf_0.002.vcf.gz --out SNP_density_of_Central_Pop_Sites_in_American_chestnut_356_snps_only_filtered_remove_fail_max_allele_2_miss_0.9_maf_0.002.tsv

#$HOME/bin/vcftools --SNPdensity 50000 --gzvcf --keep northeast_pop.txt ../American_chestnut_356_snps_only_filtered_remove_fail_max_allele_2_miss_0.9_maf_0.002.vcf.gz --out SNP_density_of_Northeast_Pop_Sites_in_American_chestnut_356_snps_only_filtered_remove_fail_max_allele_2_miss_0.9_maf_0.002.tsv

$HOME/bin/vcftools --SNPdensity 50000 --gzvcf ../American_chestnut_356_snps_only_filtered_remove_fail_max_allele_2_miss_0.9_maf_0.002.vcf.gz --out SNP_density_of_All_Pop_Sites_in_American_chestnut_356_snps_only_filtered_remove_fail_max_allele_2_miss_0.9_maf_0.002.tsv