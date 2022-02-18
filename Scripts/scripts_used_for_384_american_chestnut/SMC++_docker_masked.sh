#Beginning with v1.15.4, SMC++ is distributed as a Docker image. (Anaconda support has been discontinued.) To run the latest version of the program, type
#Type the below to run the smcpp program
#May need to install docker, and to start the docker daemon.
#sudo yum install docker
#systemctl start docker
sudo docker run --rm -v $PWD:/mnt terhorst/smcpp:latest [ARGUMENTS]

#This command will parse data for the contig chr1 for samples S1 and S2 which are members of population \
#Pop1. You should run this once for each independent contig in your dataset, producing one SMC++ output file per contig.

#Must creat a text file of the sample ids with format sample1,sample2.. in a text file, can use bcftools query -l input.vcf
#Then you must manuall add every sampleID after pop1:sample1,sample2... Depending on DAPC analysis, may want to be specific and add a pop2 or pop3
#This creates the smc file to be used
docker run --rm -v $PWD:/mnt terhorst/smcpp:latest vcf2smc \
	vcf.gz \
	outvcf_Chr1.smc.gz \
	Chr01 \
	--cores 10 \

#Potential script to use a for loop to capture all chromosomes (in this case 12)
#This one works well!
#Needs to have populations labeled with samples separated by commas. In this case I used 1 pop, but can do more. Also can make pop name whatever you'd like.
#Only supports 2 pops. So, will need to perform separately if wanting to calculate divergence times?

#This creates the smc file to be used
#for i in 01 02 03 04 05 06 07 08 09 10 11 12
#do
#docker run --rm -v $PWD:/mnt terhorst/smcpp:latest vcf2smc \
#	Chestnut_WGS_ALL_1-96_filtered_remove_fail_maf_0.01_miss_0.9.recode.vcf.gz \
#	outvcf_Chr$i.smc.gz \
#	Chr$i \
#	pop1:IYHL_PCRfree_1_NYWAYN01_CCGCGGTT_Castanea_dentata.variant2,IYHM_PCRfree_2_NYULST01_TTATAACC_Castanea_dentata.variant2 \
#	--cores 10
#done

#THIS ONE WORKS, read carefully, there are " and the & sign at the end of pop1 list
#To run in parallel, the command after -j+10 is in "", with the & added after thye quotes. -j10 says how many cores to use and make sure to include "done" and $
#This creates the smc file to be used
#####It may throw errno 13 errors. You need to temporarily suspend SELinux: sudo setenforce 0
##Masked bed file created from HudsonAlpha masked reference fasta. Converted using Daniel Cook online fasta to bed file script in notes.
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
        sem -j+10 "docker run --rm -v $PWD:/mnt terhorst/smcpp:latest vcf2smc \
                Chestnut_WGS_ALL_1-96_filtered_remove_fail_maf_0.01_miss_0.9.recode.vcf.gz \
                -m dentata_masked_repeatmasker.bed \
                outvcf_Chr$i.parallel.smc.gz \
                Chr$i \
                pop1:IYHL_PCRfree_1_NYWAYN01_CCGCGGTT_Castanea_dentata.variant2,IYHM_PCRfree_2_NYULST01_TTATAACC_Castanea_dentata.variant2" &
done
wait

#Can get estimated generation mutation rate from the analysis:
#Q : How do I get the estimated recombination rate?

#A: The model.final.json output file contains fields named rho and N0. rho is the estimated population-scaled recombination rate per base-pair. To convert it to units of generations, multiply by 2 * N0.

#Estimate step (need generation mutation rate for chestnut
#Using 1.25e-8 just as a stand in for per-generation mutation rate
#Oaks have between 4.2 and 5.2e-8 substitutions per site per generation

#docker run --rm -v $PWD:/mnt terhorst/smcpp:latest estimate -o analysis/ 5.2e-8 *.smc.gz

#Plotting the estimates
#docker run --rm -v $PWD:/mnt terhorst/smcpp:latest plot example5e8.png analysis/model.final.json

#Plotting the estimates for a specific generation time on x axis instead of convergent time (in this case 100 years as estimated for oak)
#docker run --rm -v $PWD:/mnt terhorst/smcpp:latest plot -g 100 exampleOakLength.png analysis/model.final.json

#Produce csv file and plot. The csv is useful to load into R or excel for figure development
docker run --rm -v $PWD:/mnt terhorst/smcpp:latest plot -g 100 -c exampleOakLength.png analysis/model.final.json