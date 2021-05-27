#!/usr/bin/bash

#Maybe use IMPUTE2/SHAPEIT instead of Plink for phase file: got a lot of 'Seqmentation fault' errors when using phase file derived from Plink.
#Still need to use plink first to create input files for SHAPEIT before using those files for fineStructure conversion
#Errors may also be due to an unsorted vcf file as input. When making a subsample vcf file from the original, \
#it may not be sorted. Use 'bcftools sort file.vcf' to sort the vcf file before proceeding with SHAPEIT and Plink steps.

###STEPS
##1: transform vcf using SHAPEIT
##2: Convert SHAPEIT2Chrom to produce phase files and recombination files.
##3: Run fineSTRUCTURE
##4: analysis output in R or fineSTRUCTURE interactive GUI
###################Preparing input files############################################################
#You must split the dataset by chromosomes prior to phasing since SHAPEIT phases only one chromosome at a time. To do so, you can use the following Plink command for example:

for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
     plink --file myGwasData \
           --chr Chr$i \
           --recode \
           --out myGwasData.chr$i ;
done

#Can also separate vcf filw by chromosome, ie chromosome 1
#If doing it this way, must then filter everything but biallelic sites from vcf files!
bcftools view -r Chr01 file.vcf.gz

#Filter for non-biallelic sites
bcftools view -m2 -M2 -v snps input.vcf.gz

##########################################################SHAPEIT scripts###################################################
#SHAPEIT is very slow to run on large datasets and does not scale well. 
#Make sure to remove SNPs with missing data during this step
shapeit -B gwas \
        -M genetic_map.txt \
        --output-max gwas.phased.haps gwas.phased.sample

#creating shapeit files from vcf
# -thread specifies how many threads to use for computation
#-effective population size added from smc++ estimation
#Don't have to use a genetic map, but it will make the analysis more accurate
#!/usr/bin/bash

#Below script finally worked by reducing range instead of full 89 mbp range of chr1 that ran for 10 days without conclusion
/work/amsand/Chestnut_Analysis/bin/shapeit --input-vcf /work/amsand/Chestnut_Analysis/VCF_files/Chr1_1-96_sorted.vcf \
        --input-from 1 \
        --input-to 20000 \
        --thread 14 \
        --effective-size 54000 \
        --force \
        --output-max gwasTiny.phased.haps gwasTiny.phased.sample

#--force was used because 11 individuals had >10% missing data, so this makes the program accept them

#!/bin/bash


#Creates phasefile
/work/amsand/Chestnut_Analysis/downloads/fs_4.1.1/impute2chromopainter.pl \
       gwasTiny.phased.haps \
       gwasTiny

#Creates Recombination file

/work/amsand/Chestnut_Analysis/downloads/fs_4.1.1/makeuniformrecfile.pl \
        gwasTiny.phase \
        gwasTiny.recombfile

##################################################PLINK METHOD###################################################
#Convert vcf file to proper plink1.9 files to be input for converting plink to fineStructure files
#Consider breaking down vcf files by chromosome beforehand, or will need to run plink on each chromosome here.
/work/amsand/Chestnut_Analysis/bin/plink19 \
       --vcf $WORK/Chestnut_Analysis/Admixture250000/1-96_subsample_250000.vcf \
       --recode12 \
       --const-fid \
       --allow-extra-chr \
       --autosome \
       --out plink

#Convert newly made plink files to fineStructure files
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

/work/amsand/Chestnut_Analysis/bin/fs_4.1.1/fs \
        File_Name.cp
		-idfile sampleID.ids \
        -phasefiles phase250000.phase \
        -recombfiles Recom250000.recombfile \
		-numthreads 20 \
        -go