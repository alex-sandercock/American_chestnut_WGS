#!/usr/bin/bash
###STAR index and read mapping

##Preparing files

#get arabidopsis annotated genome
cd /groups/ALS5224/LinuxProjectData/step2_inputs
cp Arabidopsis_thaliana.TAIR10.34.gtf /groups/ALS5224/G4/LinuxProject/data
cp Arabidopsis_thaliana.TAIR10.dna.toplevel.fa /groups/ALS5224/G4/LinuxProject/data


#SBATCH -J hello-world
#SBATCH -p normal_q

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=1:01:00
#SBATCH --mem-per-cpu=8G

#SBATCH --account=introtogds
#SBATCH --export=NONE 

echo "hello world"

##go to working directory
cd /groups/ALS5224/G4/LinuxProject/

#set working directory
WORKDIR=$(pwd)

#Setting input files
IDX=$WORKDIR/data/ATH_STAR_index
GTF=$WORKDIR/data/Arabidopsis_thaliana.TAIR10.34.gtf
GNM=$WORKDIR/data/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
mkdir $IDX

#build index
STAR --runMode genomeGenerate \
--genomeSAindexNbases 12 \
--genomeDir $IDX \
--genomeFastaFiles $GNM \
--sjdbGTFfile $GTF
