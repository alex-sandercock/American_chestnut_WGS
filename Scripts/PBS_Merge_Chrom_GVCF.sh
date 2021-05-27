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
#### Submit below line in same folder as target files
#### Usage to submit 1 job per sample file: find `pwd` -maxdepth 1 -iname '*.Chr01.g.vcf' -exec qsub 04_PBS_Merge_Chrom_GVCF.sh -v GVCF='{}' \;
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
################## Access group and queue, use one or the other#######max per node sfx=12/, smps are 40/#####################
#PBS -W group_list=newriver
#PBS -A adaptree
#PBS -q normal_q
#PBS -l procs=4
##PBS -l nodes=1:ppn=24
####### end of job customization

###print PBS script
PBS_script="/work/newriver/amsand/GenomeAnalysis/FASTQs/04_PBS_Merge_Chrom_GVCF.sh"
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

#Programs needed: Picard
##Step 5: Merge .g.vcf files from completed genomic regions for each sample, list must be in order!!:

#Change the '.1.fq.gz' depending on what the input file extension is.
sample=$(basename "$GVCF" .Chr01.chrom.vcf)

mkdir Sample_GVCFs
ls "sample"*.chrom.g.vcf > "$sample".GVCF.list
java -jar path_to_picard/picard.jar GatherVcfs \
    I="$sample".GVCF.list \
    O= pwd/Sample_GVCFs/"$sample".g.vcf

rm "$sample".*.chrom.g.vcf*