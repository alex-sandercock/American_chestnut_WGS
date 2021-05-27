#!/usr/bin/bash
##submitting to work node============================================================================================
#SBATCH -J hello-world
#SBATCH -p normal_q

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=2:31:00
#SBATCH --mem-per-cpu=9G

#SBATCH --account=introtogds
#SBATCH --export=NONE

echo "hello world" 

##STAR mapping 
#go to working directory
cd /groups/ALS5224/G4/LinuxProject/

#set working directory
WRKDR=$(pwd)
#Set input files=====================================================================================================
GTF=$WRKDR/data/Arabidopsis_thaliana.TAIR10.34.gtf
GNM=$WRKIR/data/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
IDX=$WRKDR/data/ATH_STAR_index
#RNA-seq Pipeline=====================================================================================================
mkdir -p $WRKDR/processed_data/ATH/bam;
cd $WRKDR/data/

for f1 in *_1.fastq;
do
f2=${f1%_1.fastq};

f3=$f2"_1.fastq"
f4=$f2"_2.fastq"

cd $WRKDR/processed_data/ATH/bam
mkdir $f2

STAR --genomeDir $IDX \
--readFilesIn $WRKDR/data/$f3 $WRKDR/data/$f4 \
--outFileNamePrefix $WRKDR/processed_data/ATH/bam/$f2/$f2 \
--outSAMtype BAM SortedByCoordinate >$WRKDR/processed_data/STAR_$f2.log;

done
