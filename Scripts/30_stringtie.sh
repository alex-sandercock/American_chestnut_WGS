#!/bin/bash
#SBATCH -J stringtie
#SBATCH -p normal_q

#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=4G

#SBATCH --account=introtogds
#SBATCH --export=NONE
echo "stringtie"
                           
cd /groups/ALS5224/G4/LinuxProject/sam_files
stringtie SRR2927328Aligned.sortedByCoord.out.bam -p 4 -G Arabidopsis_thaliana.TAIR10.34.gtf -o SRR2927328.gtf 
stringtie SRR2927329Aligned.sortedByCoord.out.bam -p 4 -G Arabidopsis_thaliana.TAIR10.34.gtf -o SRR2927329.gtf 

stringtie --merge -G Arabidopsis_thaliana.TAIR10.34.gtf -o merged.Arath.gtf /groups/ALS5224/G4/LinuxProject/data/gtf_list.txt

