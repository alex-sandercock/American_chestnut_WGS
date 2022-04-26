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
## name our process
##        <----------------------------------------------set the next line
#PBS -N Pop_C_dentata
## merge stdout and stderr
#PBS -j oe
## e-mail us when the job: '-M b' = begins, '-M a' = aborts, '-M e' = ends
#PBS -m a -M amsand@vt.edu   
#PBS -l walltime=24:00:00
################## Access group and queue, use one or the other##########################
#PBS -W group_list=newriver
#PBS -A adaptree
#PBS -q normal_q
##PBS -l procs=4
#PBS -l nodes=1:ppn=24
####### end of job customization
export MODULEPATH=/apps/packages/bio/modulefiles:$MODULEPATH
export MODULEPATH=/apps/modulefiles/stats:$MODULEPATH
module purge
module load bio/bwa/0.7.4
module load pigz
module load parallel
module load jdk/1.8.0
module load picard/1.138
module load gcc/6.1.0
module load samtools/1.3.1

###print PBS script
PBS_script="path_to_script/06_PBS_Remove_Failed_Quality_SNP.sh"
echo '#############################################################################'
more $PBS_script
echo '#############################################################################'
###########################################################################
echo start:
date
echo jobid is $PBS_JOBID
JOBID=${PBS_JOBID%%.*}
echo jobnumber is $JOBID
echo job was launched using:
echo Type set to $Type 
echo Reference set to $Reference 
echo Reads set to $Reads
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