#!/usr/bin/bash

#Maybe use IMPUTE2/SHAPEIT instead of Plink for phase file: got a lot of 'Seqmentation fault' errors when using phase file derived from Plink.
#Still need to use plink first to create input files for SHAPEIT before using those files for fineStructure conversion
#Errors may also be due to an unsorted vcf file as input. When making a subsample vcf file from the original, \
#it may not be sorted. Use 'bcftools sort file.vcf' to sort the vcf file before proceeding with SHAPEIT and Plink steps.

###STEPS
##1: transform vcf using BEAGLE 5.2
##2: Convert BEAGLE2Chrom to produce phase files and recombination files.
##3: Run fineSTRUCTURE
##4: analysis output in R or fineSTRUCTURE interactive GUI
###################Preparing input files############################################################
#First the original vcf file that had hybrids removed and individuals with >10% missing data removed (356 left)
#Then all snps with missing data were removed in plink 1.9
#VCF WAS *NOT* LD-PRUNED. fineSTRUCTURE needs a dense dataset with the SNPs still in LD.
#Looks like more methods split by chromosome, so I split the vcf file by chrome.
#There was a post that referenced speaking to the author for Beagle 4.2 and not phsaing by chromomes https://bioinformatics.stackexchange.com/questions/5334/using-beagle-4-1-for-phasing-and-ibd-chromosomes

#Breaking filtered vcf file by chromosome, with no variants with missing data
cat chr_list.txt | parallel "vcftools --gzvcf American_chestnut_356_snps_only_filtered_remove_fail_no_miss.vcf.gz --chr {} --recode --out American_chestnut_356_snps_only_filtered_remove_fail_no_miss_chr{}.vcf.gz"

#The subsequent input file preparation steps were performed separately for each chromosome.

#!/bin/bash
cd /work/C_dentata_WGS/dentata_356_prunted/IBDNe
java -Xmx24g -jar $HOME/bin/beagle.28Jun21.220.jar gt=/work/C_dentata_WGS/dentata_356_not_pruned/vcf/American_chestnut_356_snps_only_filtered_remove_fail_no_miss.vcf.gz nthreads=14 out=dentata_356_no_prune_phase

#Converting phased vcf file to plink .ped and .map (using plink 1.9) (5.27million snps)
#Only retained chromosomes, not scaffolds

/work/amsand/Chestnut_Analysis/bin/plink19 \
       --vcf $WORK/Chestnut_Analysis/Admixture250000/1-96_subsample_250000.vcf \
       --recode12 \
       --const-fid \
       --allow-extra-chr \
       --autosome \
       --out plink

#Convert newly made plink files to fineStructure files
#Make sure to output the id file too for easier submission in the next step.
##Refer to https://people.maths.bris.ac.uk/~madjl/finestructure/manualse13.html#x16-3200013 (Specifically example 13.2 for multiple chromosome use)

/work/amsand/Chestnut_Analysis/downloads/fs_4.1.1/plink2chromopainter.pl \
        -p plink.ped \
        -m plink.map \
        -o phase250000

#Converts the phase file just created into a recombination file to use with fineStructure
#Creates Recombination file

/work/amsand/Chestnut_Analysis/downloads/fs_4.1.1/makeuniformrecfile.pl \
        phase250000.phase \
        Recom250000 #Recom250000 is the output name

#################################################################################################################

#Runs fineSTRUCTURE
#There is a command in fineStructure to create ID file from phasefile to use in the analysis, fyi
#This creates a file that can be run in parallel 4 times, ie command1, command2, command3

date > dentata_356.time
fs dentata_356.cp -hpc 1 -idfile dentata_356.ids \
        -phasefiles dentata_356_painted_Chr01.phase,dentata_356_painted_Chr02.phase,dentata_356_painted_Chr03.phase,dentata_356_painted_Chr04.phase,dentata_356_painted_Chr05.phase,dentata_356_painted_Chr$
        -recombfiles Recom_dentata_356_Chr01.recombfile,Recom_dentata_356_Chr02.recombfile,Recom_dentata_356_Chr03.recombfile,Recom_dentata_356_Chr04.recombfile,Recom_dentata_356_Chr05.recombfile,Recom_dentata_356_Chr06.recombfile,Recom_dentata_356_Chr07.recombfile,Recom_dentata_356_Chr08.recombfile,Recom_dentata_356_Chr09.recombfile,Recom_dentata_356_Chr10.recombfile,Recom_dentata_356_Chr11.recombfile,Recom_dentata_356_Chr12.recombfile \
        -go

#EM files were not properly converging. Probably due to the false Ne assumption by fs (526). Change each line of the commandfiles1.txt file to manually assign the Ne to be the original SMC++ estimate of ~57,000
sed -i 's/fs cp/fs cp -n 57000/g' commandfile1.txt

##If the above doesnt work, will then have to adjust c value.        