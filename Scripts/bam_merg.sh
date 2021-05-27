#!/usr/bin/bash

input=$1

##align short reads via bwa mem
cd $WORK/Pure_American_Analysis/BAMs
sampleSMRG=$(basename ${input/_I9*/}) #CHECK TO MAKE SURE THAT THIS WILL WORK
cd $WORK/Pure_American_WGS_Samples
sample=$(basename ${input/_R1.fastq/})
outdir="$WORK/Pure_American_Analysis/SAMs2/$sample.sam" #make sure you have SAMs created. mkdir SAMs

##Convert SAM to BAM (Sorted and Indexed)
#cd /work/newriver/amsand/GenomeAnalysis/SAMs
outdir1="$WORK/Pure_American_Analysis/BAMs/$sample"
outdir2="$WORK/Pure_American_Analysis/BAMs/$sample.bam" #make sure you have "BAMs" created. mkdir BAMs
/work/newriver/amsand/GenomeAnalysis/bin/samtools merge /work/newriver/amsand/Pure_American_Analysis/Merge_BAMs/"$sample".bam "$sample"_I987_L1.bam "$sample"_I987_L2.bam "$sample"_I995_L4.bam

cd $WORK/Pure_American_Analysis/Merge_BAMs
outdir8="$WORK/Pure_American_Analysis/Merge_BAMs/$sample.bam"
/work/newriver/amsand/GenomeAnalysis/bin/samtools sort -m 3G -o $outdir8 -@ 5 && /work/newriver/amsand/GenomeAnalysis/bin/samtools index $outdir8
#DON't need to include sort if I already sorted files before merging.