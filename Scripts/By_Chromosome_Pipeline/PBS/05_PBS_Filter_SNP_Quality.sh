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
## name our process
##        <----------------------------------------------set the next line
#PBS -N Pop_C_dentata
## merge stdout and stderr
#PBS -j oe
## e-mail us when the job: '-M b' = begins, '-M a' = aborts, '-M e' = ends
#PBS -m a -M amsand@vt.edu   
#PBS -l walltime=5:00:00
################## Access group and queue, use one or the other##########################
#PBS -W group_list=newriver
#PBS -A adaptree
#PBS -q normal_q
#PBS -l procs=4
##PBS -l nodes=1:ppn=24
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
PBS_script="path_to_/05_PBS_Filter_SNP_Quality.sh"
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