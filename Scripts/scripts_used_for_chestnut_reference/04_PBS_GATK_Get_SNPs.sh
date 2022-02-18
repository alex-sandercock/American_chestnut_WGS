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
## name our process
##        <----------------------------------------------set the next line
#PBS -N Pop_C_dentata
## merge stdout and stderr
#PBS -j oe
## e-mail us when the job: '-M b' = begins, '-M a' = aborts, '-M e' = ends
#PBS -m a -M amsand@vt.edu   
#PBS -l walltime=5:00:00
################## Access group and queue, use one or the other#######################
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
PBS_script="/work/newriver/amsand/GenomeAnalysis/FASTQs/04_PBS_GATK_Get_SNPs.sh"
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

#Need to edit the above submission scripts to work for NewRiver
#Programs needed: BWA, Samtools, GenomeAnalysisTK.jar (GATK), bamaddrg


#This protocol works for PCR-free sequencing. If there is a PCR step, there is an additional GATK tool to use (MarkDuplicates).
#Programs needed: GATK, vcftools. 


#May need to delete .idx files before running next step to speed up process and allow code to make new .idx files on the fly	<- rm *.idx
#GATK automatically makes an index file if one is not present. The program usually runs faster if you let it make its own index files.
# Then you run this to merge them all together and get a SNP set across all samples

module load jdk/1.8.0

##Step 1: First need to make list of .g.vcf samples to use as input for GATK. Can customize this to specific samples that you want, but can also extract specific samples from completed VCF.
ls *.g.vcf > gatk.list  #<-- this makes a list of .vcf files to be read


##Step 2: Next use GATK to produce vcf file#####################
java -Xmx200g -jar path_to_GATK/GenomeAnalysisTK.jar \
	-T GenotypeGVCFs \
	-R path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
	--variant gatk.list \
	-o snps.vcf