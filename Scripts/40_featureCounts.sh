#!/bin/bash
#SBATCH -J hello-world
#SBATCH -p normal_q

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=8G

#SBATCH --account=introtogds
#SBATCH --export=NONE
echo "hello-world"

GTF=/groups/ALS5224/G4/LinuxProject/data/Arabidopsis_thaliana.TAIR10.34.gtf

cd /groups/ALS5224/G4/LinuxProject/sam_files
for f1 in *_1.fastq;
do

f2=${f1%_1.fastq};

mkdir /groups/ALS5224/G4/LinuxProject/processed_data/rc/$f2

bamsuffix=Aligned.sortedByCoord.out.bam
BAM=$f2$bamsuffix

/groups/ALS5224/G4/LinuxProject/bin/featureCounts -t exon \
-g gene_id \
-p \
-a $GTF \
#$BAM represents the list of input files, which is placed after the output_directory
-o /groups/ALS5224/G4/LinuxProject/processed_data/rc/$f2/$f2.readcount.txt $BAM
#also, dont use a "for loop", and instead set the input_files "$BAM" as *.bam, or *.sam. This will process all files into 1 output file instead of separate output.txt files

done
