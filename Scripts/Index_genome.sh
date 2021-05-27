#Indexing the genome using BWA

cd $WORK/DNA_Practice/Practice/data
module purge
#module load gcc/4.7.2 \
        gcc/5.2.0 \
        gcc/6.1.0 \
        intel/15.3 \
        intel/17.0 \
        bwa/0.7.12
#wget https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2/download
/work/cascades/amsand/DNA_Practice/Practice/downloads/bwa-0.7.17/bwa index -p C$

