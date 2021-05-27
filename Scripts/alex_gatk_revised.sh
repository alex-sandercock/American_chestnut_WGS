
#!/bin/bash

input=$1

##align short reads via bwa mem
sample=$(basename ${input/.1.fq.gz/})
outdir="SAMs/$sample.sam" #make sure you have SAMs created. mkdir SAMs

/work/newriver/amsand/GenomeAnalysis/bin/bwa-0.7.15/bwa mem -M -R "@RG\tID:Sample_$sample\tSM:$sample" -t 5 -p /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
        FASTQs/$sample.1.fq.gz FASTQs/$sample.2.fq.gz > $outdir #R flag is really important! not sure if you are using it...


##Convert SAM to BAM (Sorted and Indexed)
#cd /work/newriver/amsand/GenomeAnalysis/SAMs
outdir1="BAMs/$sample"
outdir2="BAMs/$sample.bam" #make sure you have "BAMs" created. mkdir BAMs
/work/newriver/amsand/GenomeAnalysis/bin/samtools view -bS $outdir | /work/newriver/amsand/GenomeAnalysis/bin/samtools sort -m 3G -o $outdir2 -@ 5 && /work/newriver/amsand/GenomeAnalysis/bin/samtools ind$

##Add read groups and re-index, for some reason bwa doesn't do this properly for me
#cd /work/newriver/amsand/GenomeAnalysis/BAMs
outdir3="RGs/$sample.rg.bam"
/work/newriver/amsand/GenomeAnalysis/bin/bamaddrg --clear -b $outdir2 > $outdir3
/work/newriver/amsand/GenomeAnalysis/bin/samtools index $outdir3

##Call SNPs per sample with haplotypecaller
#cd /work/newriver/amsand/GenomeAnalysis/RGs
outdir4="HCs/$sample.g.vcf"
java -Xmx5g -jar /work/newriver/amsand/GenomeAnalysis/bin/GenomeAnalysisTK.jar \
        -R /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
        -T HaplotypeCaller \
        -I $outdir3 \
        --emitRefConfidence GVCF \
        -o $outdir4