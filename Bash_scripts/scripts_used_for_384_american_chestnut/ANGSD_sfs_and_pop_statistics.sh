
#!/usr/bin/bash

#http://www.popgen.dk/angsd/index.php/Heterozygosity

####### job customization
## name our process
##        <----------------------------------------------set the next line
## e-mail us when the job: '-M b' = begins, '-M a' = aborts, '-M e' = ends
################## Access group and queue, use one or the other#######################

#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH -t 19:00:00
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

############Make individual chromosome SAF files ################################################

#Afterwards combine saf	chromosome files for each pop using ./realSFS cat

cd /work/cascades/amsand/Pure_American_Analysis/Sorted_Bams
/work/cascades/amsand/Pure_American_Analysis/bin/angsd -bam south_pop.list\
        -anc /work/cascades/amsand/Pure_American_Analysis/ANGSD/chinese_synthetic_genome/Chinese_Synthetic_Fa.fa \
        -ref /work/cascades/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta -dosaf 1 -gl 1 \
        -nThreads 5 \
        -r Chr01 \
        -C 50 -minQ 20 -minmapq 30 \
        -uniqueOnly 1 -only_proper_pairs 1 -remove_bads 1 \
        -out /work/cascades/amsand/Pure_American_Analysis/ANGSD/South_dentata_ANGSD_Chr01_saf

#Filters are based on Angsd heterozygosity minimum standards and the silver birch and populus davidia papers
#https://onlinelibrary.wiley.com/doi/full/10.1111/eva.13046
#https://www.nature.com/articles/ng.3862

#####################Concat the separate .saf.idx files to get a single file for SFS######################

#It practically does not require any memory, so use as many cores as you would like depending on how many multithreads.
# -P 3, 3 cores for multithreading, completing combining the South population in less than 4 hours.
#Instead of list of files, can use the line: -b file.list

cd /work/cascades/amsand/Pure_American_Analysis/ANGSD/South

/home/amsand/bin/angsd_programs/misc/realSFS cat South_dentata_ANGSD_Chr01_saf.saf.idx South_dentata_ANGSD_Chr02_saf.saf.idx South_dentata_ANGSD_Chr03_saf.saf.idx South_dentata_ANGSD_Chr04_saf.saf.idx South_dentata_ANGSD_Chr05_saf.saf.idx South_dentata_ANGSD_Chr06_saf.saf.idx South_dentata_ANGSD_Chr07_saf.saf.idx South_dentata_ANGSD_Chr08_saf.saf.idx South_dentata_ANGSD_Chr09_saf.saf.idx South_dentata_ANGSD_Chr10_saf.saf.idx South_dentata_ANGSD_Chr11_saf.saf.idx South_dentata_ANGSD_Chr12_saf.saf.idx -outnames South_dentata_merged -P 3

############################Perform SFS ##################################################

#Performing this on the 178Gb South pop saf file, with 10 threads, requires at least 113Gb of memory

/home/amsand/bin/angsd_programs/misc/realSFS South_dentata_merged.saf.idx -P 10 > output.ml

#To calculate nucleotide diversity, I referred to the papers in the ANGSD_methods folder in Zotero
#Specifically I reffered to the ANGSD Github link and the Pixy paper for their ANGSD methods
#In summary, after performing a windowed do_stat in ANGSD: "In the case of π, we explicitly divided the raw estimates of pairwise theta by the number of sites (nSites) provided by ANGSD, and not the window size (10,000).""

#######Statistics and Sliding Window Statistics ###################

#Thetas (The program only used 2.3gb of memory of the course of 3hrs)

/home/amsand/bin/angsd_programs/misc/realSFS saf2theta South_dentata_merged.saf.idx -P 18 -outname ANGSD_South -sfs ANGSD_South.sfs

#Estimate for every Chromosome/scaffold (3 minutes and 3GB of memory)
/home/amsand/bin/angsd_programs/misc/thetaStat do_stat ANGSD_South.thetas.idx

#Do a sliding window analysis based on the output from the make_bed command (3 minutes and 1.4Gb of memory)
/home/amsand/bin/angsd_programs/misc/thetaStat do_stat ANGSD_South.thetas.idx -win 50000 -step 10000  -outnames ANGSD_South_theta.thetasWindow.gz

#calculate Tajimas D
#./misc/thetaStat do_stat out.thetas.idx

############Pairwise Fst between pops ############################
#calculate all pairwise 2dsfs's
./misc/realSFS pop1.saf.idx pop2.saf.idx -P 24 >pop1.pop2.ml
./misc/realSFS pop1.saf.idx pop3.saf.idx -P 24 >pop1.pop3.ml
./misc/realSFS pop2.saf.idx pop3.saf.idx -P 24 >pop2.pop3.ml
#prepare the fst for easy analysis etc
./misc/realSFS fst index pop1.saf.idx pop2.saf.idx pop3.saf.idx -sfs pop1.pop2.ml -sfs pop1.pop3.ml -sfs pop2.pop3.ml -fstout here
#get the global estimate

#below is not tested that much, but seems to work
../misc/realSFS fst stats2 here.fst.idx -win 50000 -step 10000 >slidingwindow

