
!/bin/bash

input=$1

cd $WORK/GenomeAnalysis/HCs
#americn_gatk.list is a list of the specific bam files I want to use for the VCF file
java -Xmx200g -jar $WORK/GenomeAnalysis/bin/GenomeAnalysisTK.jar \
        -T GenotypeGVCFs \
        -R $WORK/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
        --variant /work/newriver/amsand/GenomeAnalysis/HCs/american_gatk.list \
        -o american_snps.vcf



#java -Xmx200g -jar $WORK/GenomeAnalysis/bin/GenomeAnalysisTK.jar \
 #  -T VariantFiltration \
 #  -R $WORK/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
 #  -o $WORK/GenomeAnalysis/Results/snps_filtered.vcf \
 #  --variant $WORK/GenomeAnalysis/Results/snps.vcf \
 #  --filterExpression "QD < 2.0" \
 #  --filterName "MQ" \
 #  --filterExpression "MQ < 40.00" \
 #  --filterName "MQ" \
 #  --filterExpression "FS > 40.000" \
 #  --filterName "FS" \
 #  --filterExpression "MQRankSum < -12.500" \
 #  --filterName "MQRankSum" \
 #  --filterExpression "ReadPosRankSum < -8.000" \
 #  --filterName "ReadPosRankSum" \
 #  --filterExpression "SOR > 3.0" \
 #  --filterName "SOR"

## This will delete SNPs that didn't pass the quality check above
#java -Xmx200g -jar $WORK/GenomeAnalysis/bin/GenomeAnalysisTK.jar \
 #  -R $WORK/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
  # -T SelectVariants \
  # -V $WORK/GenomeAnalysis/Results/snps_filtered.vcf \
  # -o $WORK/GenomeAnalysis/Results/snps_filtered_remove_fail.vcf \
  # -ef

## Finally I use vcftools to filter on missing data (<10%)
## I also put a working copy of vcftools in your folder
#$WORK/GenomeAnalysis/bin/vcftools --vcf $WORK/GenomeAnalysis/Results/snps_filtered_remove_fail.vcf --max-alleles 2 --max-missing 0.9 \
#	--out $WORK/GenomeAnalysis/Results/snps_filtered_remove_fail_maf_0.01_miss_0.9 --recode
