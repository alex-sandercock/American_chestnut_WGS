
#!/usr/bin/bash
#SBATCH -J chestnut
#SBATCH -p normal_q

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=4G

#SBATCH --account=jah1_lab
#SBATCH --export=NONE
#echo "chestnut"
#-----------------------------------------------------------------------
# Code to Analyze nucleotide diversity in Chinese Chestnut hybrids. Says to use 'pegas', but that should be the same as poppr
#This function computes the nucleotide diversity from a sample of DNA sequences or a set of haplotypes.
##module load gcc/6.1.0
##module load R/3.6.0
install.packages("pegas")
#Make a for loop to pull files from ARC?
nuc.div(x, ...)
## S3 method for class 'DNAbin'
nuc.div(x, variance = FALSE, pairwise.deletion = FALSE, ...)
## S3 method for class 'haplotype'
nuc.div(x, variance = FALSE, pairwise.deletion = FALSE, ...)

#_______________________________________________________________________________
