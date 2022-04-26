#!/usr/bin/bash



###############################################################################
###      @author: Alex Sandercock                                           ###
###        November 2020                                                    ###
###Launch in target directory                                               ###
###need to use absolute path for files                                      ###
####                                										###
####
#### Use standard qsub job submission: qsub ./04_PBS_GATK_Get_SNPs.sh
###############################################################################

####### job customization 
#PBS -l walltime=5:00:00
#PBS -W group_list=newriver
#PBS -A adaptree
#PBS -q normal_q
#PBS -l procs=4
##PBS -l nodes=1:ppn=24
####### end of job customization
module purge
module load bio/bwa/0.7.4
module load parallel
module load jdk/1.8.0
module load picard/1.138
module load gcc/6.1.0
module load samtools/1.3.1
###########################################################################

#Need to edit the above submission scripts to work for NewRiver
#Programs needed: GenomeAnalysisTK.jar (GATK)


#This protocol works for a PCR step, there is an additional GATK tool to use (MarkDuplicates).

#May need to delete .idx files before running next step to speed up process and allow code to make new .idx files on the fly	<- rm *.idx
#GATK automatically makes an index file if one is not present. The program usually runs faster if you let it make its own index files.
# Then you run this to merge them all together and get a SNP set across all samples

##Step 1: First need to make list of .g.vcf samples to use as input for GATK. Can customize this to specific samples that you want, but can also extract specific samples from completed VCF.
ls *.g.vcf > gatk.list  #<-- this makes a list of .vcf files to be read

##Step 2: Next use GATK to produce vcf file#####################
java -Xmx200g -jar path_to_GATK/GenomeAnalysisTK.jar \
	-T GenotypeGVCFs \
	-R path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
	--variant gatk.list \
	-o snps.vcf