#Using beagle to impute a vcf file
#I think a reference file is required for the dataset to be imputed.
java -Xmx24g -jar /programs/beagle41/beagle41.jar gt=/workdir/moshood/snps/snp_filtered.vcf.gz.recode.vcf nthreads=8 niterations=0  out=imputed_file