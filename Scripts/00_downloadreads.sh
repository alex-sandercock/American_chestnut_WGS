#!/usr/bin/bash

###Making directories for files====================================================================

cd /groups/ALS5224/G4/LinuxProject
mkdir scripts data downloads bin results

###Downloading/loading software=====================================================================

#Download and install STAR

cd /groups/ALS5224/G4/LinuxProject/downloads
git clone https://github.com/alexdobin/STAR.git
cd STAR/bin
cd Linux_x86_64_static
cp STAR /groups/ALS5224/G4/LinuxProject/bin

#Download and install samtools

cd /groups/ALS5224/G4/LinuxProject/downloads
wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
tar -xvf samtools-1.9.tar.bz2
mv samtools-1.9/ /groups/ALS5224/G4/LinuxProject/bin
cd /groups/ALS5224/G4/LinuxProject/bin/samtools-1.9/
./configure --prefix=/groups/ALS5224/G4/LinuxProject/bin/samtools-1.9/
make 
make install

#Download and install stringtie

cd /groups/ALS5224/G4/LinuxProject/downloads
wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.0.3.Linux_x86_64.tar.gz
tar -xvf stringtie-2.0.3.Linux_x86_64.tar.gz
cd stringtie-2.0.3.Linux_x86_64
cp stringtie /groups/ALS5224/G4/LinuxProject/bin

#Download and install featureCounts

cd /groups/ALS5224/G4/LinuxProject/downloads
wget https://sourceforge.net/projects/subread/files/subread-2.0.0/subread-2.0.0-Linux-x86_64.tar.gz/download
tar -xvf download
rm download
cd /groups/ALS5224/G4/LinuxProject/downloads/subread-2.0.0-Linux-x86_64/
cd bin
cp featureCounts /groups/ALS5224/G4/LinuxProject/bin
mv subread-2.0.0-Linux-x86_64/ /groups/ALS5224/G4/LinuxProject/downloads
	
#Download and install sra-toolkit

cd /groups/ALS5224/G4/LinuxProject/downloads
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
tar -xvf sratoolkit.current-ubuntu64.tar.gz
mv sratoolkit.2.9.6-1-ubuntu64/ /groups/ALS5224/G4/LinuxProject/bin


##====================================================================================


###Downloading files
###Only pick these 2 SRR files to run for this project

cd /groups/ALS5224/G4/LinuxProject/data
SRRID="SRR2927328 SRR2927329"

for eachfile in $SRRID
do
  	echo "this is $eachfile"
        /groups/ALS5224/G4/LinuxProject/bin/sratoolkit.2.9.6-1-ubuntu64/bin/fastq-dump -I --split-files $eac$
done

