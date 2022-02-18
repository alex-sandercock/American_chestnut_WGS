###Steps:
#1. dentata_356_filtered vcf file was filtered so that any snps with missing information were removed. (refer to fineSTRUCTURE data prep)
#2. VCF file was separated by chromosome using bcftools and then each chromosome was separately phased using BEAGLE 5.2
#3. The separate chromosome vcf files were then merged back together with only the chromosomes 1-12 retained
#3a bcftools concat -o dentata_356_phase_Chr1-12_merged.vcf.gz dentata_356_Chr01_phase.vcf.gz dentata_356_Chr02_phase.vcf.gz dentata_356_Chr03_phase.vcf.gz dentata_356_Chr04_phase.vcf.gz dentata_356_Chr05_phase.vcf.gz dentata_356_Chr06_phase.vcf.gz dentata_356_Chr07_phase.vcf.gz dentata_356_Chr08_phase.vcf.gz dentata_356_Chr09_phase.vcf.gz dentata_356_Chr10_phase.vcf.gz dentata_356_Chr11_phase.vcf.gz dentata_356_Chr12_phase.vcf.gz
#3b. The chromome names had to be changed to only numbers instead of Chr#, to conform to the genetic map labels:
#sed 's/^Chr01\s/1\t/g; s/^Chr02\s/2\t/g; s/^Chr03\s/3\t/g; s/^Chr04\s/4\t/g; s/^Chr05\s/5\t/g; s/^Chr06\s/6\t/g; s/^Chr07\s/7\t/g; s/^Chr08\s/8\t/g; s/^Chr09\s/9\t/g; s/^Chr10\s/10\t/g; s/^Chr11\s/11\t/g; s/^Chr12\s/12\t/g' plink.bim > fixed_plink.bim
#4. hap-IBD was used with the Tatyana cranberry/chestnut genetic distance map and the combined phased vcf file to find IBD segments.
#5. The resulting IBD segments were used for the IBDNe analysis.


