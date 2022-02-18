#!/usr/bin/bash



###############################################################################
###      @author: Alex Sandercock                                           ###
###        November 2020                                                    ###
###Launch in target directory                                               ###
###need to use absolute path for files                                      ###
####                                										###
####
###Need to submit the below script in the same folder that the target files are in.
#### Usage to submit 1 job per sample file: find `pwd` -maxdepth 1 -iname '*bam' -exec sbatch --export=SAMFILE='{}' path_to_script/02_SBATCH_Sam2Bam.sh \;
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
#SBATCH --cpus-per-task=5
#SBATCH -t 5:00:00
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
PBS_script="/work/newriver/amsand/GenomeAnalysis/FASTQs/02_SBATCH_Sam2Bam.sh"
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

##Step 2: Convert SAM to BAM (Sorted and Indexed)

#Change the '.sam' depending on what the input file extension is.
sample=$(basename "$SAMFILE" .sam)

outdir="/work/newriver/amsand/GenomeAnalysis/SAMs/$sample.sam"
outdir1="/work/newriver/amsand/GenomeAnalysis/BAMs/$sample.bam"
outdir2="/work/newriver/amsand/GenomeAnalysis/BAMs/$sample.bam" #make sure you have "BAMs" created. mkdir BAMs
samtools view -Sb "$outdir" | samtools sort -o "$outdir1" && samtools index "$outdir1"
