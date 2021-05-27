#!/usr/bin/bash

cd $WORK/Pure_American_Analysis/GATK_by_Chrom/sample_21
for sample in $(more chromosome_21.list)
do
java -Xmx5g -jar /work/newriver/amsand/Pure_American_Analysis/bin/GenomeAnalysisTK.jar \
        -R /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
        -T HaplotypeCaller \
        -L $sample \
        -I /work/newriver/amsand/Pure_American_Analysis/GATK_by_Chrom/sample_21/IYIH_PCRfree_21_VAAMHE02_GGTACCTT_Castanea_dentata.bam \
        --emitRefConfidence GVCF \
        -o $sample.g.vcf
done

#chromosome_21.list is a list of the chromosomes and scaffolds from the original merged bam file.
#TO make a list of the chromosomes and scaffolds use: samtools idxstats sample.bam | cut -f 1 > ls chromosome_sample.list

#To run it in parallel use:
#This is only by individual sample, would need to create a parallel script to run on more than 1 sample
#This next step may seem like its not running, just leave the screen and look at the folder to see if the individual files are being produced.
cd $WORK/Pure_American_Analysis/GATK_by_Chrom/sample_21

foo () {
	java -Xmx5g -jar /work/newriver/amsand/Pure_American_Analysis/bin/GenomeAnalysisTK.jar \
        -R /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
        -T HaplotypeCaller \
        -L $sample \
        -I /work/newriver/amsand/Pure_American_Analysis/GATK_by_Chrom/sample_21/IYIH_PCRfree_21_VAAMHE02_GGTACCTT_Castanea_dentata.bam \
        --emitRefConfidence GVCF \
        -o sample21_$sample.g.vcf
}
for sample in $(more chromosome_21.list); do foo "$sample" & done

#Merge .g.vcf files from completed chromosomes/:
ls *.g.vcf > chrGVCF.list
java -jar $WORK/Pure_American_Analysis/bin/picard.jar GatherVcfs \
    I=chrGVCF.list \
    O=sample.g.vcf

##May need to delete .idx files before running next step to speed up process and allow code to make new .idx files on the fly	
## Then you run this to merge them all together and get a SNP set across all samples
# ls *.g.vcf > gatl.list  <-- this makes a list of .vcf files to be read
java -Xmx200g -jar path_to_GATK/GenomeAnalysisTK.jar \
	-T GenotypeGVCFs \
	-R path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
	--variant list_of_samples.list \
	-o snps.vcf

##Can't use a zipped vcf file, ie sample_name.vcf.gz. It must be unzipped as it is in the previous output
## Filter this set for quality
## this code may throw a bunch of warnings; ignore them
java -Xmx200g -jar path_to_GATK/GenomeAnalysisTK.jar \
  -T VariantFiltration \
  -R path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
  -o snps_filtered.vcf \
  --variant snps.vcf \
  --filterExpression "QD < 2.0" \
  --filterName "MQ" \
  --filterExpression "MQ < 40.00" \
  --filterName "MQ" \
  --filterExpression "FS > 40.000" \
  --filterName "FS" \
  --filterExpression "MQRankSum < -12.500" \
  --filterName "MQRankSum" \
  --filterExpression "ReadPosRankSum < -8.000" \
  --filterName "ReadPosRankSum" \
  --filterExpression "SOR > 3.0" \
  --filterName "SOR" 	

## This will delete SNPs that didn't pass the quality check above
java -Xmx200g -jar path_to_GATK/GenomeAnalysisTK.jar \
  -R path_to_reference_genome/Castanea_dentata.mainGenome.fasta \
  -T SelectVariants \
  -V snps_filtered.vcf \
  -o snps_filtered_remove_fail.vcf \
  -ef

## Finally I use vcftools to filter on missing data (<10%) 
## I also put a working copy of vcftools in your folder
path_to_vcftools --vcf snps_filtered_remove_fail.vcf --max-alleles 2 --max-missing 0.9 \
	--out snps_filtered_remove_fail_maf_0.01_miss_0.9 --recode

#Possible way to merge separate completed vcf files
java -jar GenomeAnalysisTK.jar \
   -T CombineVariants \
   -R reference.fasta \
   --variant input1.vcf \
   --variant input2.vcf \
   -o output.vcf \
   -genotypeMergeOptions UNIQUIFY #<- use this option to make sure that each sample has a unique name incase there is duplicate names.
   #Can input a list of vcf's in the --variant option to merge if there are more than one.


#module load parallel
#module load jdk/1.8.0 
## better memory handling, only 50 jobs at a time
#parallel --load 90% --memfree 10G ./GATK_only_parallel_wgs.sh ::: $(more chromosome_sample.list | cat)