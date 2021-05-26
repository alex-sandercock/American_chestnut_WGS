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


##Step 4: This will delete SNPs that didn't pass the quality check above
java -Xmx200g -jar path_to_GATK/GenomeAnalysisTK.jar \
   -R path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
   -T SelectVariants \
   -V snps_filtered.vcf \
   -o snps_filtered_remove_fail.vcf \
   -ef