#!/bin/bash

vcftools --remove-indv YOUR_INDIVIDUALS_NAME --vcf your_snps.vcf --recode --out your_filtered_snps.vcf

#--remove-indv only removes the sample listed, --remove allows the input of a list of sample names.