#!/usr/bin/bash

input=$1

module load parallel
module load jdk/1.8.0

##align short reads via bwa mem
#cd $WORK/Pure_American_Analysis/Merge_BAMs
cd $WORK/Pure_American_Analysis/BAMs
sample=$(basename ${input/.bam/})
sampleRGSM=$(basename ${input/_I9*.bam/}) #CHECK TO MAKE SURE THAT THIS WILL WORK
outdir="$WORK/Pure_American_Analysis/SAMs2/$sample.sam" #make sure you have SAMs created. mkdir SAMs

##Convert SAM to BAM (Sorted and Indexed)
#cd /work/newriver/amsand/GenomeAnalysis/SAMs
outdir1="$WORK/Pure_American_Analysis/BAMs/$sample"
outdir2="$WORK/Pure_American_Analysis/BAMs/$sample.bam" #make sure you have "BAMs" created. mkdir BAMs
#/work/newriver/amsand/GenomeAnalysis/bin/samtools merge /work/newriver/amsand/Pure_American_Analysis/Merge_BAMs/"$sample".bam "$sample"_I987_L1.bam "$sample"_I987_L2.bam "$sample"_I995_L4.bam

cd $WORK/Pure_American_Analysis/Merge_BAMs
outdir8="$WORK/Pure_American_Analysis/Merge_BAMs/$sample.bam"
#/work/newriver/amsand/GenomeAnalysis/bin/samtools sort -m 3G -o $outdir8 -@ 5 && /work/newriver/amsand/GenomeAnalysis/bin/samtools index $outdir8
#DON't need to include sort if I already sorted files before merging.
outdir9="$WORK/Pure_American_Analysis/RGs/$sample.rg.bam"

java -jar /work/newriver/amsand/Pure_American_Analysis/bin/picard.jar AddOrReplaceReadGroups \
        CREATE_INDEX=true \
        I= /work/newriver/amsand/Pure_American_Analysis/BAMs/"$sample".bam \
        O= /work/newriver/amsand/Pure_American_Analysis/RGs/"$sample".rg.bam \
        RGID=Sample_"$sample" \
        RGLB=Lib1 \
        RGPL=Illumina \
        RGPU=SampleLabel_"$sample" \
        RGSM="$sampleRGSM"

    #Need to include RGLB, RGPL, RGPU even though they are not used in other analysis at the moment.
    #This script must be run on all bam files before they are merged, if not, then the meged bams will have different SMs which will cause GATK to not work.
    #In the future, the RG's should be changed when reading the FASTQ files.
    #Need to run this in parallel...parallel -j12 ./gatk.sh ::: $(ls FASTQs/*.1.fq.gz | cat)