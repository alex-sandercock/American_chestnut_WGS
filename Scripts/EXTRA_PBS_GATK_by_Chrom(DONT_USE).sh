#!/usr/bin/bash



###############################################################################
###      @author: Bob Settlage                                                                                          ###
###        Data Analysis Core @ the Virginia Bioinformatics Institute                                                   ###
###        December 2011                                                                                                ###
###Launch in target directory                                                                                           ###
###need reference                                                                                                       ###
###need file to map                                                                                                     ###
###align paired reads independently                    ###
###need to 
###        use absolute path for files                                                                                  ###
#### usage for SE/PE:  qsub /groups/DAC/useful_PBS/PBS_Popoolation_2_align.sh -v Results=_good,Reference=transcripts.fa,Reads=reads.fastq                               ###
####
####Need to submit the below script in the same folder that the target files are in.
#### Usage to submit 1 job per sample file: find `pwd` -maxdepth 1 -iname '*.bam' -exec qsub 03_PBS_GATK_by_Chrom.sh -v BAMFILE='{}' \;
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
################## Access group and queue, use one or the other#######max per node sfx=12/, smps are 40/#####################
#PBS -W group_list=newriver
#PBS -A adaptree
#PBS -q normal_q
#PBS -l procs=12,pmem=10gb
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
PBS_script="/work/newriver/amsand/GenomeAnalysis/FASTQs/01_PBS_Align.sh"
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

##Step 3: create a list of chromosomes and scaffolds in bam file.
#In this script, I was doing it for sample 36

#Change the '.1.fq.gz' depending on what the input file extension is.
sample=$(basename "$BAMFILE" .bam)

cd path_to_merged_bam_file_folder
samtools idxstats "$sample".bam | cut -f 1 > ls "$sample".list

##Step 4: run GATK on each chromosome/scaffold.
#the foo command runs this in parallel. 
#The output is a separate .g.vcf file for each.
#the below script runs, even if it looks like it isn't initially. Just back out of the screen and check the folder to see of the files started appearing.
foo () {
        java -Xmx5g -jar path_to_GATK/GenomeAnalysisTK.jar \
        -R /path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
        -T HaplotypeCaller \
        -L "$chromosome" \
        -I path_to_merged_bam_file/IYIY_PCRfree_36_ALETOW02_GATTCTGC_Castanea_dentata.bam \
        --emitRefConfidence GVCF \
        -o "$sample"."$chromosome".chrom.vcf
}
for chromosome in $(more "$sample".list); do foo "$chromosome" & done
