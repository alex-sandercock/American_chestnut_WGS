#!/usr/bin/bash



###############################################################################
###      @author: Alex Sandercock                                           ###
###        November 2020                                                    ###
###Launch in target directory                                               ###
###need to use absolute path for files                                      ###
####                                										###
####
#### Usage to submit: sbatch ./07_SBATCH_VCFtools_remove_missing_data.sh
###############################################################################

####### job customization
#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH -t 36:00:00
####### end of job customization


#Need to edit the above submission scripts to work for NewRiver
#Programs needed: vcftools


##Step 5: Finally I use vcftools to filter on missing data (<10%) 
#Should we also filter out INDELs, so that only SNPs remain?
path_to_vcftools --vcf snps_filtered_remove_fail.vcf --max-alleles 2 --max-missing 0.9 \
	--out snps_filtered_remove_fail_miss_0.9 --recode