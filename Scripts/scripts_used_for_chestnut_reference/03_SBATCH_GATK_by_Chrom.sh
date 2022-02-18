
#!/usr/bin/bash



###############################################################################
###      @author: Alex Sandercock                                           ###
###        November 2020                                                    ###
###Launch in target directory                                               ###
###need to use absolute path for files                                      ###
####                                                                        ###
####
####Need to submit the below script in the same folder that the target files are in.
#### Usage to submit 1 job per sample file: find `pwd` -maxdepth 1 -iname '*.bam' -exec sbatch --export=BAMFILE='{}' /work/newriver/amsand/Pure_American_Analysis/WGS_97-192/scripts/03_SBATCH_GATK_by_Chrom.sh \;
###############################################################################

################## Access group and queue, use one or the other###########################

#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH -t 24:00:00
##I think that 30 hrs, 16 cores is sufficient. Just adjust parallel to have memfree 4G and -j 12.
####### end of job customization
export MODULEPATH=/apps/packages/bio/modulefiles:$MODULEPATH
export MODULEPATH=/apps/modulefiles/stats:$MODULEPATH
module purge
module load intel/15.3
module load bwa/0.7.12
module load parallel
module load jdk/1.8.0
module load samtools/1.3.1
module load parallel

###print PBS script
PBS_script="/work/newriver/amsand/Pure_American_Analysis/WGS_97-192/scripts/03_PBS_GATK_by_Chrom.sh"
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
echo "${BAMFILE%%.*}".bam
echo $BAMFILE

###########################################################################
#############################Create Node Directories##############################################
#TMPDIR is 1.8T SAS storage and TMPFS is allocated memory storage on NewRiver for normal_q

node_DIR=$TMPDIR/$JOBID
mkdir $node_DIR
##########################################################################
#Make a new folder, ie GVCF, and submit script from there. DO NOT SUBMIT SCRIPT FROM BAM FILE FOLDER OR HAVE ANY OUTPUTS DIRECTED THERE.

cd /work/newriver/amsand/Pure_American_Analysis/WGS_97-192/BAMs/bam_97-132
#Programs needed: GenomeAnalysisTK.jar (GATK)

##Step 3: create a list of chromosomes and scaffolds in bam file.

#Change the '.bam' depending on what the input file extension is.
sample=$(basename "$BAMFILE" .bam)
echo "$sample"
echo "${BAMFILE%%.*}"

#Need to use path to samtools since module for samtools has stopped working
#creates list of chromosomes and scaffolds to use...should be in order
/path_to_samtools/samtools idxstats "${BAMFILE%%.*}".bam | cut -f 1 > /work/newriver/amsand/Pure_American_Analysis/WGS_97-192/BAMs/bam_97-132/"$sample".list

##run GATK on each chromosome/scaffolds
#The output is a separate .g.vcf file for each.
#-j tells the amount a processes to run at a time. In this case it is 22 for a 32 core/128 gb memory node.
#Also using --memfree to make sure another job does not start until the node has at least 10gb of memory free

cat "$sample".list | parallel --verbose --memfree 10G --retries 10 -j 20 "java -Xmx5g -jar /home/amsand/bin/GenomeAnalysisTK.jar \
    -R /work/newriver/amsand/ChestnutPureGenome/Castanea_dentata.mainGenome.fasta \
    -T HaplotypeCaller \
    -L {} \
    -I "$BAMFILE" \
    --emitRefConfidence GVCF \
    -o $node_DIR/"$sample".{}.chrom.g.vcf"

wait

#Wait tells the script to not run the next commands until all of the previous commands are complete from the HaplotypeCaller step

cd $node_DIR/
#Next script combines all of the individual chromosome files into a single .g.vcf file
ls "$sample"*.chrom.g.vcf > "$sample".GVCF.list
java -jar $HOME/bin/picard.jar GatherVcfs \
    I="$sample".GVCF.list \
    O="$sample".g.vcf

wait

rm "$sample".*.chrom.g.vcf*

###########################copy the results back########################
#Change $WORK/GenomeAnalysis/BAMs_Test/ to desired location for .g.vcf files
echo cp $node_DIR/ $work_DIR/  ####<---change this to go to results dir
cd $node_DIR/
ls -lah
cp -va * /work/newriver/amsand/Pure_American_Analysis/WGS_97-192/GVCFs/
rm $node_DIR/ -r
