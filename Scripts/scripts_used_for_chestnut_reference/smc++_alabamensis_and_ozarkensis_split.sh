#!/usr/bin/bash

cd /work/C_dentata_WGS/dentata_356_filtered/SMC++

mkdir alabamensis Alabamensis_and_Ozarkensis

#Need to use the dataset that containes both dentata and species reference! The later scripts require using both populations and the same VCF

#This command fits two-population clean split models using marginal estimates produced by estimate. To use split, first estimate each population marginally using estimate:

for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
        sem -j+10 "docker run --rm -v $PWD:/mnt terhorst/smcpp:latest vcf2smc \
                Castanea_species_reference_92_filtered_remove_fail_miss_0.9.recode.vcf.gz \
                alabamensis/alabamensis_Chr$i.parallel.smc.gz \
                Chr$i \
                pop2:ALAB01,ALAB02,ALAB03,ALAB05,ALAB06" &
done
wait

#for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
#        sem -j+10 "docker run --rm -v $PWD:/mnt terhorst/smcpp:latest vcf2smc \
#                Castanea_species_reference_92_filtered_remove_fail_miss_0.9.recode.vcf.gz \
#                Ozarkensis/ozarkensis_Chr$i.smc.gz \
#                Chr$i \
#                pop1:OZAR02,OZAR06,OZAR08,OZAR04,OZAR05,OZAR03,OZAR09,OZAR07,OZAR01,CHIN01" &
#done
#wait

#$ smc++ vcf2smc my.vcf.gz data/pop1.smc.gz <contig> pop1:ind1_1,ind1_2
#$ smc++ vcf2smc my.vcf.gz data/pop2.smc.gz <contig> pop2:ind2_1,ind2_2
#$ smc++ estimate -o pop1/ <mu> data/pop1.smc.gz
#$ smc++ estimate -o pop2/ <mu> data/pop2.smc.gz

#Next, create datasets containing the joint frequency spectrum for both populations:

#$ smc++ vcf2smc my.vcf.gz data/pop12.smc.gz <contig> pop1:ind1_1,ind1_2 pop2:ind2_1,ind2_2

for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
        sem -j+10 "docker run --rm -v $PWD:/mnt terhorst/smcpp:latest vcf2smc \
                Castanea_species_reference_92_filtered_remove_fail_miss_0.9.recode.vcf.gz \
                Alabamensis_and_Ozarkensis/OA_Chr$i.smc.gz \
                Chr$i \
                pop1:OZAR02,OZAR06,OZAR08,OZAR04,OZAR05,OZAR03,OZAR09,OZAR07,OZAR01,CHIN01 \
                pop2:ALAB01,ALAB02,ALAB03,ALAB05,ALAB06" &
done
wait


#$ smc++ vcf2smc my.vcf.gz data/pop21.smc.gz <contig> pop2:ind2_1,ind2_2 pop1:ind1_1,ind1_2

for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
        sem -j+10 "docker run --rm -v $PWD:/mnt terhorst/smcpp:latest vcf2smc \
                Castanea_species_reference_92_filtered_remove_fail_miss_0.9.recode.vcf.gz \
                Alabamensis_and_Ozarkensis/AO_Chr$i.smc.gz \
                Chr$i \
                pop1:ALAB01,ALAB02,ALAB03,ALAB05,ALAB06 \
                pop2:OZAR02,OZAR06,OZAR08,OZAR04,OZAR05,OZAR03,OZAR09,OZAR07,OZAR01,CHIN01" &
done
wait

#Finally, run split to refine the marginal estimates into an estimate of the joint demography:

#$ smc++ split -o split/ pop1/model.final.json pop2/model.final.json data/*.smc.gz
docker run --rm -v $PWD:/mnt terhorst/smcpp:latest split -o Alabamensis_and_Ozarkensis/split/ Ozarkensis/model.final.json alabamensis/model.final.json Alabamensis_and_Ozarkensis/*.smc.gz
#$ smc++ plot joint.pdf split/model.final.json