#!/bin/bash

input=$1

##align short reads via bwa mem
sample=$(basename ${input/.1.fq.gz/}) 
sampleRGSM=$(basename ${input/_I9*/})
outdir="SAMs/$sample.sam" #make sure you have SAMs created. mkdir SAMs

/work/newriver/jah1/software/bwa-0.7.15/bwa mem -M -R "@RG\tID:Sample_$sample\tSM:$sample" -t 5 -p /work/newriver/jah1/genomes/american_chestnut_v2/Castanea_dentata.mainGenome.fasta \
	FASTQs/$sample.1.fq.gz FASTQs/$sample.2.fq.gz > $outdir #R flag is really important! not sure if you are using it...


##Convert SAM to BAM (Sorted and Indexed)
#cd /work/newriver/amsand/GenomeAnalysis/SAMs?
outdir1="BAMs/$sample"
outdir2="BAMs/$sample.bam" #make sure you have "BAMs" created. mkdir BAMs
/work/newriver/jah1/software/samtools/samtools view -Sb $outdir | /work/newriver/jah1/software/samtools/samtools sort -m 3G - $outdir1 -@ 5 && /work/newriver/jah1/software/samtools/samtools index $outdir2

##Add read groups and re-index, for some reason bwa doesn't do this properly for me
#cd /work/newriver/amsand/GenomeAnalysis/BAMs?
outdir3="RGs/$sample.rg.bam"
/work/newriver/jah1/software/bamaddrg/bamaddrg --clear -b $outdir2 > $outdir3
/work/newriver/jah1/software/samtools/samtools index $outdir3

##Call SNPs per sample with haplotypecaller
#cd /work/newriver/amsand/GenomeAnalysis/RGs?
outdir4="HCs/$sample.g.vcf"
java -Xmx5g -jar /work/newriver/jah1/software/GenomeAnalysisTK.jar \
	-R /work/newriver/jah1/genomes/american_chestnut_v2/Castanea_dentata.mainGenome.fasta \
	-T HaplotypeCaller \
	-I $outdir3 \
	--emitRefConfidence GVCF \
	-o $outdir4

#I list all of my small scripts like this and comment/uncomment based on what I would like to run. And simply call this script within parallel (see below line)

#1. screen 
# (control^ + a + d) alows your to exit screen.
#2. qsub -I -W group_list=newriver -q normal_q -l nodes=1:ppn=24 -l walltime=96:00:00 -A adaptree -bea #Enter the account name, -bea sends emails
#For some reason the qsub script only likes to run on newriver?
#3. screen -r
#4. module load parallel
#5. module load jdk/1.8.0 
## better memory handling, only 50 jobs at a time
#parallel -j12 ./gatk.sh ::: $(ls FASTQs/*.1.fq.gz | cat)
#the above line will run master.sh for all the sample seperately by monitoring the processor and memory load (e.g. it is not going to start a job till overall load of the node is less than 85% AND 10G free memory available. 
#You can adjust this according to your use. I sometimes completely remove --load if I have too many samples and running time is really short (couple mins), so it finishes faster.
#Check here is as well https://www.gnu.org/software/parallel/parallel_tutorial.html#Progress-information. There is really cool features like. --eta --progress and --joblog you may want to use.
#parallel --load 80% --memfree 100G -j $(ls FASTQs/*.1.fq.gz | wc -l) ./pipeline_alignment_and_SNPs_american.sh ::: $(ls FASTQs/*.1.fq.gz | cat)
