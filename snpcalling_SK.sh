file=$1
ss=$2
/public/home/sswu/software/bowtie2-2.1.0/bowtie2 -q --phred33 --very-fast --end-to-end -p 8 -x /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -1 /public/home/sswu/sequence/${file}/Clean/${ss}/${ss}_1.alltrimed.fq.gz -2 /public/home/sswu/sequence/${file}/Clean/${ss}/${ss}_2.alltrimed.fq.gz -S /public/home/sswu/sequence/graduation/SK/bam/${ss}.fast.sam
head -n 673 /public/home/sswu/sequence/graduation/SK/bam/${ss}.fast.sam >/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.head
grep "AS:" /public/home/sswu/sequence/graduation/SK/bam/${ss}.fast.sam |grep -v "XS:" >/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.sam
grep "YT:Z:CP" /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.sam>/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired.sam
cat /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.head /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired.sam >/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired1.sam
samtools view -bS /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired1.sam > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired.bam
java -Xmx10g -jar /public/home/sswu/software/picard-tools-1.119/AddOrReplaceReadGroups.jar INPUT=/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired.bam OUTPUT=/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.addrg.bam SORT_ORDER=coordinate RGID=${ss} RGLB=lib${ss} RGPL=ILLUMINA RGPU="unkn-0.0" RGSM=bowtie2.fast.gatk
java -Xmx10g -jar /public/home/sswu/software/picard-tools-1.119/SortSam.jar INPUT=/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.addrg.bam OUTPUT=/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.addrg.sort.bam SORT_ORDER=coordinate
java -Xmx10g -jar /public/home/sswu/software/picard-tools-1.119/BuildBamIndex.jar INPUT=/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.addrg.sort.bam
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T RealignerTargetCreator -I /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.addrg.sort.bam -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.intervals
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T IndelRealigner -targetIntervals /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.intervals -I /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.addrg.sort.bam -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.bam
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T UnifiedGenotyper -I /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.bam -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.gatk.raw1.vcf --read_filter BadCigar -glm BOTH -stand_call_conf 30.0 -stand_emit_conf 0
/public/home/sswu/software/samtools-0.1.19/samtools mpileup -DSugf /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.bam | /public/home/sswu/software/samtools-0.1.19/bcftools/bcftools view -Ncvg - > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.samtools.raw1.vcf
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T SelectVariants --variant /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.samtools.raw1.vcf --concordance /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.gatk.raw1.vcf -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.raw1.vcf
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T VariantFiltration --filterExpression "QD < 20.0 || ReadPosRankSum < -8.0 ||  FS > 10.0 || QUAL < 30"  --filterName LowQualFilter --variant /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.raw1.vcf --missingValuesInExpressionsShouldEvaluateAsFailing --logging_level ERROR -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.flt1.vcf
grep -v "Filter" /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.flt1.vcf > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.filter1.vcf
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T BaseRecalibrator -I /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.bam -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.recal_data.grp -knownSites /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.filter1.vcf
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T PrintReads -I /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.bam -o /public/home/sswu/sequence/graduation/SK/recall_file/${ss}.fast.recal.bam -BQSR /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.recal_data.grp
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T UnifiedGenotyper -I /public/home/sswu/sequence/graduation/SK/recall_file/${ss}.fast.recal.bam -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.gatk.raw2.vcf --read_filter BadCigar -glm BOTH -stand_call_conf 30.0 -stand_emit_conf 0
/public/home/sswu/software/samtools-0.1.19/samtools mpileup -DSugf /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa /public/home/sswu/sequence/graduation/SK/recall_file/${ss}.fast.recal.bam |/public/home/sswu/software/samtools-0.1.19/bcftools/bcftools view -Ncvg - > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.samtools.raw2.vcf
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T SelectVariants --variant /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.samtools.raw2.vcf --concordance /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.gatk.raw2.vcf -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.raw2.vcf
java -Xmx10g -jar /public/home/sswu/software/GenomeAnalysisTK/GATK.jar -R /public/home/sswu/sequence/ref/SK/maize_chromosome_final.fa -T VariantFiltration --filterExpression "QD < 10.0 || ReadPosRankSum < -8.0 || FS > 10.0 || QUAL < 30" --filterName LowQualFilter --variant /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.raw2.vcf --missingValuesInExpressionsShouldEvaluateAsFailing --logging_level ERROR -o /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.flt2.vcf
grep -v "Filter" /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.concordance.flt2.vcf >/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.vcf
grep -v "INDEL" /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.vcf >/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.vcf
grep "INDEL" /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.vcf > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.indel.vcf
cat /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.snps.head /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.indel.vcf > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.Indel.vcf
#rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.indel.vcf
cat /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.vcf | /public/home/sswu/software/vcftools-0.1.15/bin/vcf-annotate --filter SnpCluster=2,5 > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.Cluster.vcf
grep -v "SnpCluster" /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.Cluster.vcf > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.cluster.vcf
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.Cluster.vcf
#cat /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.cluster.vcf | /public/home/sswu/software/vcftools-0.1.15/bin/vcf-annotate --filter MaxDP=40 > /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snp.cluster.DP.vcf
#grep -v "MaxDP" /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snp.cluster.DP.vcf >/public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.cluster.dp.vcf
#rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snp.cluster.DP.vcf
#cp /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.final.snps.cluster.dp.vcf /public/home/sswu/sequence/graduation/SK/callsnp_result_final/${ss}.final.filter.vcf
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.addrg.sort.dd.bam
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.intervals
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.bam
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.recal_data.grp
#rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.recal.bam
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.addrg.dd.metrics
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.realn.bai
#rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.recal.bai
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired.sam
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.uiq.addrg.sort.dd.bai
#rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.sam
#rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.sam
rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired1.sam
#rm -rf /public/home/sswu/sequence/graduation/SK/callsnp_result/${ss}.fast.uiq.paired.bam