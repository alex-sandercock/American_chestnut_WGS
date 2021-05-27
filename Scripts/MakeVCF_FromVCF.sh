#!/bin/bash

for file in $WORK/GenomeAnalysis/R_Files/*.vcf.gz; do
    bcftools view -Oz -S chinese_bam.txt $file.gz > "${i##*/}"_.vcf.gz
done