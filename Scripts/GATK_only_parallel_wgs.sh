#!/bin/bash
#qsub -I -W group_list=newriver -q largemem_q -l nodes=1:ppn=60 -l walltime=144:00:00 -A adaptree
#qsub -I -W group_list=newriver -q normal_q -l nodes=1:ppn=24 -l walltime=144:00:00 -A adaptree
#qsub -I -W group_list=newriver -q dev_q -l nodes=1:ppn=24 -l walltime=1:00:00 -A adaptree

input=$1

##align short reads via bwa mem
sample=$(basename ${input/.rg.bam/}) 
#outdir="SAMs/$sample.sam" #make sure you have SAMs created. mkdir SAMs

#/work/newriver/jah1/software/bwa-0.7.15/bwa mem -R "@RG\tID:Sample_$sample\tSM:$sample" -t 5 /work/newriver/jah1/genomes/american_chestnut_v2/Castanea_dentata.mainGenome.fasta \
#	FASTQs/$sample.R1.fastq.gz FASTQs/$sample.R2.fastq.gz > $outdir #R flag is really important! not sure if you are using it...


##Convert SAM to BAM (Sorted and Indexed)
#outdir1="BAMs/$sample"
#outdir2="BAMs/$sample.bam" #make sure you have "BAMs" created. mkdir BAMs
#/work/newriver/jah1/software/samtools/samtools view -Sb $outdir | /work/newriver/jah1/software/samtools/samtools sort -m 3G - $outdir1 -@ 5 && /work/newriver/jah1/software/samtools/samtools index $outdir2

##Add read groups and re-index, for some reason bwa doesn't do this properly for me
outdir3="RGs/unfinished/$sample.rg.bam"
#/work/newriver/jah1/software/bamaddrg/bamaddrg --clear -b $outdir2 > $outdir3
#/work/newriver/jah1/software/samtools/samtools index $outdir3

##Call SNPs per sample with haplotypecaller
outdir4="HCs/repeat_unfinished/$sample.g.vcf"
java -Xmx5g -jar /work/newriver/jah1/software/GenomeAnalysisTK.jar \
	-R /work/newriver/jah1/genomes/american_chestnut_v2/Castanea_dentata.mainGenome.fasta \
	-T HaplotypeCaller \
	-I $outdir3 \
	--emitRefConfidence GVCF \
	-o $outdir4

#I list all of my small scripts like this and comment/uncomment based on what I would like to run. And simply call this script within parallel (see below line)
#module load parallel
#module load jdk/1.8.0 
## better memory handling, only 50 jobs at a time
#parallel --load 90% --memfree 10G ./GATK_only_parallel_wgs.sh ::: $(ls RGs/unfinished/*.rg.bam | cat)
#the above line will run master.sh for all the sample seperately by monitoring the processor and memory load (e.g. it is not going to start a job till overall load of the node is less than 85% AND 10G free memory available. 
#You can adjust this according to your use. I sometimes completely remove --load if I have too many samples and running time is really short (couple mins), so it finishes faster.
#Check here is as well https://www.gnu.org/software/parallel/parallel_tutorial.html#Progress-information. There is really cool features like. --eta --progress and --joblog you may want to use.
#parallel -j 50 $(ls FASTQs/*.R1.fastq.gz | wc -l) ./BWA_GATK_parallel_wgs.sh ::: $(ls FASTQs/*.R1.fastq.gz | cat)
