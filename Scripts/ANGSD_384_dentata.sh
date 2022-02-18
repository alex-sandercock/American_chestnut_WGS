#!/usr/bin/bash

##ANGSD for 384_dentata::Methods for Paper1

####### job customization
## name our process
##        <----------------------------------------------set the next line
## e-mail us when the job: '-M b' = begins, '-M a' = aborts, '-M e' = ends
################## Access group and queue, use one or the other#######################

#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH -t 48:00:00
####### end of job customization

#Want to calculate:
#ABBA-BABA
#SFS
#Tajimas D
#Fst
#Nucleotide Diversity
#Heterozygosity levels throughout range

################################Make Ancestral Fasta############################################

#First needed to create an ancestra fasta from multible chinese chestnut bam files

	-> angsd version: 0.933-106-gb0d8011 (htslib: 1.11-28-g78441c9-dirty) build(Jan  5 2021 14:22:19)
	-> /home/amsand/bin/angsd -b mollissima_bam_list.txt -doFasta 2 -doCounts 1 -out Chinese_Synthetic_Fa -nThreads 8

#List of mollissima used based on 100% purity from admixture
MOLL01.bam
MOLL02.bam
MOLL03.bam
MOLL04.bam
MOLL08.bam
MOLL11.bam
MOLL15.bam
MOLL16.bam
MOLL18.bam
MOLL19.bam
MOLL20.bam


########################SFS--needs to be performed for each pop ################################


#First need to get the site allele frequency spectrum:
#Since we do not have ancestral state file, we apply reference genome to -anc, then we must use -fold 1 in the realSFS steps
#Check manual, performing without ancestral file and using -fold 1 changes some of the output file dimensions.
#For performing an SFS and prerequisite SAF, you do not want to filter for maf.
#cd /work/newriver/amsand/Pure_American_Analysis/Merged_BAMs
#/work/newriver/amsand/Pure_American_Analysis/bin/angsd -bam 93_Bam.list \
	#-P 32 -out /work/newriver/amsand/Pure_American_Analysis/Nucleotide_Diversity/saf_1-93 \
	#-trim 0 -C 50 -baq 1 \
	#-minMapQ 20 -minQ 20 -doCounts 1 \
	#-ref /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
	#-anc /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \ 
	#-GL 2 -doSaf 1



#################################################################################################

##########################Follow-up analyses ####################################################

#To Bootstrap the data to check if wanted
#bootstrap the SFS. Which can be very usefull for getting confidence intervals of the estimated SFS.
realSFS pop.saf.idx -bootstrap 100 -P number_of_cores

#Calculate thetas 
realSFS saf2theta out.saf.idx -sfs out.sfs -outname out 
#output from the above command are two files out.thetas.gz and out.thetas.idx

#Tajimas D
./misc/thetaStat do_stat out.thetas.idx

#Sliding window analysis
thetaStat do_stat out.thetas.idx -win 50000 -step 10000  -outnames theta.thetasWindow.gz


############################################Graphing the SFS in R################################

###In R
sfs<-scan("smallFolded.sfs")
barplot(sfs[-1])

#To make fancy in R
#function to normalize
norm <- function(x) x/sum(x)
#read data
sfs <- (scan("small.sfs"))
#the variability as percentile
pvar<- (1-sfs[1]-sfs[length(sfs)])*100
#the variable categories of the sfs
sfs<-norm(sfs[-c(1,length(sfs))]) 
barplot(sfs,legend=paste("Variability:= ",round(pvar,3),"%"),xlab="Chromosomes",
names=1:length(sfs),ylab="Proportions",main="mySFS plot",col='blue')

################################################################################################