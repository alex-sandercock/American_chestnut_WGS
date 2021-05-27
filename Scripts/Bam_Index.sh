#!/usr/bin/bash

#SBATCH -J hello-world
#SBATCH -p normal_q

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=5:00:00
#SBATCH --mem-per-cpu=24G

#SBATCH --account=introtogds
#SBATCH --export=NONE

echo "hello-world"

cd $WORK/DNA_Practice/Practice/results/bam_sorted

for f in *_sorted.bam
do
$WORK/DNA_Practice/Practice/bin/samtools-1.9/samtools index "$f" > $WORK/DNA_Practice/Practice/results/bam_sorted/"${f%_sorted.bam}_sortedIndex.bam"

done

