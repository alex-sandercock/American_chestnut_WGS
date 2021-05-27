

#!/usr/bin/bash



###############################################################################
###      @author: Alex Sandercock                                           ###
###        November 2020                                                    ###
###Launch in target directory                                               ###
###need to use absolute path for files                                      ###
####                                                                        ###
####
####Need to submit the below script in the same folder that the target files are in.
#### Usage to submit 1 job per sample file: find path_to_bam_files/ -maxdepth 1 -iname '*.bam' -exec qsub 03_PBS_GATK_by_Chrom.sh -v BAMFILE='{}' \;
###############################################################################

####### job customization
## name our process
##        <----------------------------------------------set the next line
#PBS -N Pop_C_dentata
## merge stdout and stderr
#PBS -j oe
## e-mail us when the job: '-M b' = begins, '-M a' = aborts, '-M e' = ends
#PBS -m a -M amsand@vt.edu   
#PBS -l walltime=24:00:00
################## Access group and queue, use one or the other###########################
#PBS -W group_list=newriver
#PBS -A adaptree
#PBS -q normal_q
#PBS -l nodes=1:ppn=24
####### end of job customization
export MODULEPATH=/apps/packages/bio/modulefiles:$MODULEPATH
export MODULEPATH=/apps/modulefiles/stats:$MODULEPATH
module purge
module load intel/15.3
module load bwa/0.7.12
module load parallel
module load jdk/1.8.0
module load samtools/1.3.1

###print PBS script
PBS_script="/work/newriver/amsand/GenomeAnalysis/FASTQs/03_PBS_GATK_by_Chrom.sh"
echo '#############################################################################'
more $PBS_script
echo '#############################################################################'
###########################################################################
echo start:
date
echo jobid is $PBS_JOBID
JOBID=${PBS_JOBID%%.*}
echo jobnumber is $JOBID
echo job was launched using:
echo Type set to $Type 
echo Reference set to $Reference 
echo Reads set to $Reads
###########################################################################
#############################Create Node Directories##############################################
#TMPDIR is 1.8T SAS storage and TMPFS is allocated memory storage on NewRiver for normal_q

node_DIR=$TMPDIR/$JOBID
mkdir $node_DIR
##########################################################################
#Make a new folder, ie GVCF, and submit script from there. DO NOT SUBMIT SCRIPT FROM BAM FILE FOLDER OR HAVE ANY OUTPUTS DIRECTED THERE.

cd path_to_BAM_files
#Programs needed: GenomeAnalysisTK.jar (GATK)

##Step 3: create a list of chromosomes and scaffolds in bam file.

#Change the '.bam' depending on what the input file extension is.
sample=$(basename "$BAMFILE" .bam)
echo "$sample"
echo "${BAMFILE%%.*}"

#creates list of chromosomes and scaffolds to use...should be in order
samtools idxstats "${BAMFILE%%.*}".bam | cut -f 1 > path_to_current_folder/"$sample".list

##run GATK on each chromosome/scaffold.
#The output is a separate .g.vcf file for each.

for chromosome in $(more "$sample".list); do
	(
	java -Xmx5g -jar /home/amsand/bin/GenomeAnalysisTK.jar \
        	-R /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
        	-T HaplotypeCaller \
        	-L "$chromosome" \
        	-I "$BAMFILE" \
        	--emitRefConfidence GVCF \
        	-o $node_DIR/"$sample"."$chromosome".chrom.g.vcf
	) &
done
wait

#Wait tells the script to not run the next commands until all of the previous commands are complete from the for loop

cd $node_DIR/
#Next script combines all of the individual chromosome files into a single .g.vcf file
ls "$sample"*.chrom.g.vcf > "$sample".GVCF.list
java -jar /path_to_picard/picard.jar GatherVcfs \
    I="$sample".GVCF.list \
    O="$sample".g.vcf

wait

rm "$sample".*.chrom.g.vcf*

###########################copy the results back########################
#Change $WORK/GenomeAnalysis/BAMs_Test/ to desired location for .g.vcf files
echo cp $node_DIR/ $work_DIR/  ####<---change this to go to results dir
cd $node_DIR/
ls -lah
cp -va * path_to_current_folder/
rm $node_DIR/ -r
