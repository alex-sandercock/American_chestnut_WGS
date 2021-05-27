!/usr/bin/bash

#SBATCH -J hello-world
#SBATCH -p normal_q

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=16G

#SBATCH --account=introtogds
#SBATCH --export=NONE

echo "hello world"

cd $WORK/DNA_Practice/Practice/results/bam

#cd $WORK/DNA_Practice/Practice/results/bam

for f in *.bam; do #Designates what file extension to look for
    $WORK/DNA_Practice/Practice/bin/samtools-1.9/samtools sort "$f" -o "${f%.bam}_sorted.bam"
    #Usually should write sort in.file -o out.file>>>but i already have the input file as a bam file so not needed. -o just designates the output file to be a bam file.

done