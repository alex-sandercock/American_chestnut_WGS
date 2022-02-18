#!/usr/bin/bash

###############################################################################
###      @author: Alex Sandercock                                           ###
###        November 2020                                                    ###
###Launch in target directory                                               ###
###need to use absolute path for files                                      ###
####                                										###
####
#### Usage to submit 1 job per sample file: find `pwd` -maxdepth 1 -iname '*R1.fastq' -exec sbatch --export=FASTAFILE='{}' /work/newriver/amsand/Pure_American_Analysis/WGS_193-384/scripts/01_SBATCH_Align.sh \;
###############################################################################

####### job customization
## name our process
##        <----------------------------------------------set the next line
#PBS -N Pop_C_dentata
## merge stdout and stderr
#PBS -j oe

#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH -t 3:00:00
####### end of job customization

#######ADD MODULES############################################################
module purge
module load parallel
module load jdk/1.8.0
module load intel/15.3
module load bwa/0.7.12

###print PBS script
PBS_script="/work/newriver/amsand/Pure_American_Analysis/WGS_193-384/scripts/01_SBATCH_Align.sh"
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
echo $FASTAFILE
###########################################################################

##Only submits 48 jobs at one time (ARC limit); I would run in screen to avoid the excess error messages if trying to submit more than 48 jobs.
#This script will take fasta files with the extension *.fq.gz and produce sam files
#This script will not work as-is for the current fasta files we receive from HudsonAlpha due to the different file extension names and multiple lanes per sample.

#There is also -execdir (implemented by most find variants, but not a standard option).
#This works like -exec with the difference that the given shell command is executed with the directory of the found pathname as its current working directory and that {} will contain the basename of the $

#Submit script in same folder as the target fastq files.

##Step 1: align short reads via bwa mem

cd /work/cascades/amsand/Pure_American_Analysis/WGS_193-384/FASTQ_redo
input=$FASTAFILE

#Change the '_R1.fastq' depending on what the input file extension is.
sample=$(basename "$FASTAFILE" _R1.fastq.bz2)
sampleRGSM=$(basename ${input/_I1*.fastq.bz2/})
#The sampleRGSM label is only necessary if multiple lanes have been used for sequencing. It is important the each sample has the same SM label, but different ID labels for each lane.

outdir="/work/cascades/amsand/Pure_American_Analysis/WGS_193-384/BAMs/"$sample".bam" #make sure you have SAMs created. mkdir SAMs

#bwa mem -M -R "@RG\tID:Sample_"$sample"\tSM:"$sampleRGSM"" -t 27 /work/cascades/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
#        "${FASTAFILE%%_R1*}"_R1.fastq "${FASTAFILE%%_R1*}"_R2.fastq > "$outdir" #R flag is really important! not sure if you are using it...


$HOME/bin/bwa mem -M -R "@RG\tID:Sample_"$sample"\tSM:"$sampleRGSM"" -t 27 /work/cascades/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
        <(bunzip2 -c "${FASTAFILE%%_R1*}"_R1.fastq.bz2) \
	<(bunzip2 -c "${FASTAFILE%%_R1*}"_R2.fastq.bz2) | $HOME/bin/samtools sort -@20 -o "$outdir" -