#!/usr/bin/bash

#Might need to use Plink1, since Plink2 gives errors
#Use plink first to create plink files (.bed etc)

/work/newriver/amsand/Pure_American_Analysis/downloads/Plink/plink \
	--vcf $WORK/Pure_American_Analysis/Filtered_VCF/Chestnut_WGS_ALL_1-96_filtered_remove_fail_maf_0.01_miss_0.9.recode.vcf.gz \
	--const-fid 0 #Makes the family numbers constant
	--make-bed
	#Need to lookup and add an option to include the non-chromosomes (scaffolds) otherwise, it won't

#Top script may not work. Can use Plink2 instead of Plink (diff software) and use the code below.

/work/amsand/Chestnut_Analysis/bin/plink2 \
        --vcf $WORK/Chestnut_Analysis/Admixture100000/1-96_subsample_100000.vcf \
        --make-bed \
	--const-fid 0 #Makes the family numbers constant
        --allow-extra-chr \
	--max-alleles 2 \
	--allow-extra-chr \
	--autosome
        --out plink
        #Allow-extra-chr includes scaffolds with chromosomes; --autosome then exludes anything outside of the 12 chromosomes
	#Converting to plink1 format does not allow multi-allelic sites (--max-alleles 2)

#Next need to alter plink.bim file so that the chromosomes are only labeled with their number
#Make sure to change the original .bim file to a different name, then change fixed_plink.bim to just plink.bim
sed 's/^Chr01\s/1\t/g; s/^Chr02\s/2\t/g; s/^Chr03\s/3\t/g; s/^Chr04\s/4\t/g; s/^Chr05\s/5\t/g; s/^Chr06\s/6\t/g; s/^Chr07\s/7\t/g; s/^Chr08\s/8\t/g; s/^Chr09\s/9\t/g; s/^Chr10\s/10\t/g; s/^Chr11\s/11\t/g; s/^Chr12\s/12\t/g' plink.bim > fixed_plink.bim

#Now start admixure to test for k 1-7
#By default cross-validation(cv) is 5. This can be changed to 10, for example, by using --cv=10
#Then set -j based on the number of processors available.
#Should be a way to parallelize this by doing each individual k number simultaneously. Currently, it going through 1 at a time.

for K in 1 2 3 4 5 6 7; \
	do /work/newriver/amsand/Pure_American_Analysis/downloads/dist/admixture_linux-1.3.0/admixture --cv plink.bed $K -j20 | tee log${K}.out; done

#Then compare the CV scores (lowest one is the best). Can graph in excel or R if it is not immediately obvious.
grep -h CV log*.out
	
#Then run ADMIXTURE for the K value that you chose to be the best
# 3 is the K value used in this example, and -j4 is the number of processors to use (We should use 20ish since a node is 24)

path_to_admixture ~Data/huge_dataset.bed 3 -j4

#Use R to graph https://www.discovermagazine.com/the-sciences/analyzing-ancestry-with-admixture-step-by-step