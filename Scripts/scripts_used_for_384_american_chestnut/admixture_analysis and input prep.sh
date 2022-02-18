#!/usr/bin/bash

#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH -t 36:00:00
####### end of job customization

#--set-missing-var-ids was used to set custom variant ids for each snp so that LD pruning could be performed.

cd /work/amsand/admixture_filtered_dentata

/home/amsand/bin/Plink/plink \
        --vcf /work/amsand/VCF/American_chestnut_356_snps_only_filtered_remove_fail_miss_0.9_maf_0.002.vcf.gz \
        --const-fid 0 \
        --set-missing-var-ids @:#[Cd]\$1,\$2 \
        --allow-extra-chr \
        --autosome \
        --make-bed

wait

/home/amsand/bin/Plink/plink --bfile plink --indep-pairwise 50 10 0.1

wait

/home/amsand/bin/Plink/plink --bfile plink --extract plink.prune.in --make-bed --out prunedData

##ADMIXTURE#####

#The script below is an example for a single k value, however, K values of 1-8 were evaluated. The K value was just altered for each separate run.

#!/usr/bin/bash

#SBATCH -A adaptree
#SBATCH -p normal_q
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH -t 96:00:00
####### end of job customization

cd $WORK/admixture_filtered_dentata

$HOME/bin/admixture_linux-1.3.0/admixture prunedData.bed --cv 7 -j120 | tee log7.out

#THE CV error scores were then evaluated and the lowest value was chosen as the 'best' value for K. In this case, 3.

#######Other optional methods that I did not use ########

#Now that the lowest K value has been chosen, ADMIXTURE was run 10 times at that K value to "deals with local minimum problems"
#These were then visualized using 'pong' software package. https://link.springer.com/protocol/10.1007/978-1-0716-0199-0_4#Sec3
#Alternatively, the run with the 'best' log-likelihood value can be chosen (I think this is the highest value) (O'conner notes:https://si.biostat.washington.edu/sites/default/files/modules/Day1_PM_part1.pdf)