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
#PBS -l walltime=24:00:00
#PBS -W group_list=newriver
#PBS -A adaptree
#PBS -q normal_q
##PBS -l procs=4
#PBS -l nodes=1:ppn=24
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

cd $WORK/Pure_American_Analysis/GVCFs

##Step 4: This will combine the filtered vcf files before the final vcftools filter
java -Xmx120g -jar /work/newriver/amsand/Pure_American_Analysis/bin/GenomeAnalysisTK.jar \
   -T CombineVariants \
   -R /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
   --variant snps_96_filtered_remove_fail.vcf \
   --variant /work/newriver/amsand/Pure_American_Analysis/WGS_97-192/VCF/97-192_American_chestnut_snps_filtered_remove_fail.vcf \
   --variant snps_193-384_p1_filtered_remove_fail.vcf \
   --variant snps_193-384_p2_filtered_remove_fail.vcf \
   -o American_chestnut_WGS_384_samples_filtered_remove_fail.vcf \
   -genotypeMergeOptions UNIQUIFY #<- use this option???