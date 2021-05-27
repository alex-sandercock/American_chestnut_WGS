#!/bin/bash

#Use this to remove Chr and scaffold_ from chromosome and scaffold names for Plink imput

awk '{gsub(/^Chr/,""); print}' your.vcf > no_chr.vcf

awk '{gsub(/^scaffold_/,""); print}' no_chr.vcf > no_scaffold_no_chr.vcf