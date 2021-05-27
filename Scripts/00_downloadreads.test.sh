#!/usr/bin/bash

#### Creates test files for fastq

echo $(pwd)

for SRR in `cat /groups/ALS5224/G4/LinuxProject/data/filelist.txt`
do
  	echo $SRR
        /groups/ALS5224/G4/LinuxProject/bin/sratoolkit.2.9.6-1-ubuntu64/bin/fastq-dump -X 5 --split-files $SRR --outdir ./test
done

mv /groups/ALS5224/G4/LinuxProject/scripts/test /groups/ALS5224/G4/LinuxProject/data
