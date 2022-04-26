#!/usr/bin/bash



###############################################################################
###      @author: Alex Sandercock                                           ###
###        November 2020                                                    ###
###Launch in target directory                                               ###
###need to use absolute path for files                                      ###
####                                                              ###
####
#### Usage to submit: qsub ./05_PBS_Filter_SNP_Quality.sh
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

##Step 3: Filter this set for quality
#this code may throw a bunch of warnings; ignore them
java -Xmx200g -jar path_to_GATK/GenomeAnalysisTK.jar \
   -T VariantFiltration \
   -R path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
   -o snps_filtered.vcf \
   --variant snps.vcf \
   --filterExpression "QD < 2.0" \
   --filterName "MQ" \
   --filterExpression "MQ < 40.00" \
   --filterName "MQ" \
   --filterExpression "FS > 40.000" \
   --filterName "FS" \
   --filterExpression "MQRankSum < -12.500" \
   --filterName "MQRankSum" \
   --filterExpression "ReadPosRankSum < -8.000" \
   --filterName "ReadPosRankSum" \
   --filterExpression "SOR > 3.0" \
   --filterName "SOR" 	