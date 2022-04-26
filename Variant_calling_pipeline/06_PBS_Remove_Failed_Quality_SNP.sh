#!/usr/bin/bash



###############################################################################
###      @author: Alex Sandercock                                           ###
###        November 2020                                                    ###
###Launch in target directory                                               ###
###need to use absolute path for files                                      ###
####                                										###
####
#### Usage to submit: qsub ./06_PBS_Remove_Failed_Quality_SNP.sh
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

#Programs needed:GenomeAnalysisTK.jar (GATK)


##Step 4: This will delete SNPs that didn't pass the quality check above
java -Xmx200g -jar path_to_GATK/GenomeAnalysisTK.jar \
   -R path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
   -T SelectVariants \
   -V snps_filtered.vcf \
   -o snps_filtered_remove_fail.vcf \
   -ef