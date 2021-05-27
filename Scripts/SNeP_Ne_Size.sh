#!/usr/bin/bash

#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH -t 48:00:00

########################Need to first make .ped and .map files for use in SNeP################################################

##Might be easier to just use vcftools

$HOME/bin/vcftools --gzvcf /work/newriver/amsand/Pure_American_Analysis/Filtered_VCF/Chestnut_WGS_ALL_1-96_filtered_remove_fail_maf_0.01_miss_0.9.recode.vcf.gz \
	--plink \
	--out WORK/Chestnut_Analysis/SNeP/snep_plink

#Might need to use Plink1, since Plink2 gives errors

$HOME/bin/plink19 \
        --vcf /work/amsand/Chestnut_Analysis/SNeP/input_files/American_chestnut_10k.vcf \
        --recode \
        --const-fid 0 \
        --allow-extra-chr \
        --out snep2_files

#############################################################################################################################

###################################### Now we can perform SNeP ##############################################################

#The followwing will automatically detect the .map file as long as it has the same root file as the .ped file
#All SNeP runs automatically add an maf of 0.05 unless specified.

$HOME/bin/SNeP1.1 \
	-threads 32 \
	-ped /work/cascades/amsand/CHestnut_Analysis/SNeP/snep_plink.ped