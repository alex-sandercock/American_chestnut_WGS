#/usr/bin/bash

#This removes repeats from PCR library prep
#The American chestnut samples were prepared using PCR-free library prep, so they did not use this script. 
#This was used for the other Castanea species which were prepared with a PCR step.
#MAKE SURE TO USE THIS AFTER MERGING BAMS IF MULTIPLE LANES HAVE BEEN USED FOR A SAMPLE!!!
#Input must be a sorted and indexed bam file.
#Have this performed in TMPFS to speed up processing.

java -Xmx110g -jar picard.jar MarkDuplicates \
      I=input.bam \
      REMOVE_DUPLICATES=true \ 
      CREATE_INDEX=true \
      O=marked_duplicates.bam \
      M=marked_dup_metrics.txt