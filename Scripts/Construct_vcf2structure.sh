#!/bin/bash

####### job customization
## name our process
##        <----------------------------------------------set the next line
#PBS -N Pop_C_dentata
## merge stdout and stderr
#PBS -j oe
## e-mail us when the job: '-M b' = begins, '-M a' = aborts, '-M e' = ends
#PBS -m a -M amsand@vt.edu
#PBS -l walltime=10:00:00
################## Access group and queue, use one or the other###########################
#PBS -W group_list=newriver
#PBS -A adaptree
#PBS -q normal_q
#PBS -l nodes=1:ppn=12
####### end of job customization
export MODULEPATH=/apps/packages/bio/modulefiles:$MODULEPATH
export MODULEPATH=/apps/modulefiles/stats:$MODULEPATH
module purge
module load bio/bwa/0.7.4
module load pigz
module load parallel
module load jdk/1.8.0
module load picard/1.138
module load gcc/6.1.0
module load samtools/1.3.1
###########################################
cd $WORK/Pure_American_Analysis/STRUCTURE

/home/amsand/bin/Plink/plink \
        --vcf /work/newriver/amsand/Pure_American_Analysis/Filtered_VCF/Chestnut_WGS_ALL_1-96_filtered_remove_fail_maf_0.01_miss_0.9.recode.vcf.gz \
        --const-fid 0 \
        --allow-extra-chr \
        --recode structure \
        --out structure1-96

#Then delete first two lines of output file so that the first line of the structure file begins with the sample ID.
sed '1,2d' structure1-96_10k.recode.strct_in > mynewfile.txt