#/usr/bin/bash

#This removes repeats from PCR library prep
#MAKE SURE TO USE THIS AFTER MERGING BAMS IF MULTIPLE LANES HAVE BEEN USED FOR A SAMPLE!!!
#Input must be a sorted and indexed bam file.
#Have this performed in TMPFS to speed up processing?

java -Xmx110g -jar picard.jar MarkDuplicates \
      I=input.bam \
      REMOVE_DUPLICATES=true \ 
      CREATE_INDEX=true \
      O=marked_duplicates.bam \
      M=marked_dup_metrics.txt