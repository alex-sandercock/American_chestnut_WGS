#Use this to edit the headers in the bam files to include the sample names for gatk
#Must use sorted bam files

#to view the header to check, use: samtools view -H input_file | grep '@RG'
for f in *.bam; do
path_to_bamaddrg --clear -b infile.bam > outfile.bam

done