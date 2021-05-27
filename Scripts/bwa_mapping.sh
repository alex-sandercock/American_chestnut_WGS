#!/usr/bin/bash

#SBATCH -J hello-world
#SBATCH -p normal_q

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=0:10:00#48:00:00
#SBATCH --mem-per-cpu=127G

#SBATCH --account=introtogds
#SBATCH --export=NONE

echo "hello world"
##If needing to go to a specific folder, use this...
#total_files=`find -name 'folder_name/*.fq' | wc -l`
#arr=( $(ls folder_name/*.fq) )

##If not, use this
cd $WORK/DNA_Practice/Practice/data
##>>>>>!!>!>!>>!WARNING, WILL PRODUCE SAM FILES THAT ARE MISSING ID and SM IN THE @RG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
total_files=`find -name '*.fq.gz' | wc -l`
arr=( $(ls *.fq.gz) )

echo "mapping started" >> map.log
echo "---------------" >> map.log

for ((i=0; i<$total_files; i+=2))
{
sample_name=`echo ${arr[$i]} | awk -F "_" '{print $1}'`
echo "[mapping running for] $sample_name"
printf "\n"
echo "bwa mem -M -R "@RG\tID:Sample_$sample\tSM:$sample" -t 5 Castanea_dentata.mainGenome.fasta ${arr[$i]} ${arr[$i+1]} > $sample_name.sam" >> map.log
$WORK/DNA_Practice/Practice/data/bwa mem -M -R "@RG\tID:Sample_$sample\tSM:$sample" -t 5 /work/cascades/amsand/DNA_Practice/Practice/data/Castanea_dentata.mainGenome.fasta ${arr[$i]} ${arr[$i+1]} >$sample_name.sam

}

#Follow along using the numbers below as line numbers to the script above.

#3.Counting number of files that end in *.fastq. If your files have different endings then substitute accordingly.
#4.Assigning the names of the files to an array called arr.
#5.Just printing a message to screen and append to log file called map.log.
#6.Just printing a message to screen and append to log file called map.log.
#8. A for loop to step through the array taking two file names at a time (this is a paired-end dataset so forward and reverse pair, will need to change depending on your use case) until you take all elements from array. Array elements start at position [0].
#10.sample_name extracts the actual name of the sample (stuff before first _ e.g. Sample1 from Sample1_fastq)
#12.Printing the name you are working with to screen with echo
#13.Printing the actula command you are working with. Name of output file created using $sample_name as $sample_name.sam.
#14.Run the actual bwa mem command.