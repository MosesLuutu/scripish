#! /bin/bash

start=$SECONDS
echo $HOSTNAME

cd /Users/geraldmboowa/crimescene\ /

bwa index -a bwtsw /Volumes/BACKUP/Human_reference/human_g1k_v37.fasta

java -jar /Users/geraldmboowa/picard/build/libs/picard.jar CreateSequenceDictionary REFERENCE=/Volumes/BACKUP/Human_reference/human_g1k_v37.fasta OUTPUT=/Volumes/BACKUP/Human_reference/human_g1k_v37.dict

samtools faidx /Volumes/BACKUP/Human_reference/human_g1k_v37.fasta


for sample in `cat my-sample-list.txt`
do   
    R1=${sample}_R1.fastq.gz
    R2=${sample}_R2.fastq.gz
    
bwa mem -R  "@RG\tID:0\tSM:${sample}\tPL:Illumina" /Volumes/BACKUP/Human_reference/human_g1k_v37.fasta $R1 $R2 > ${sample}.sam

samtools view -bh ${sample}.sam > ${sample}.bam

java -jar /Users/geraldmboowa/picard/build/libs/picard.jar SortSam I= ${sample}.bam O=${sample}_sorted.bam SORT_ORDER=coordinate

java -Xmx4g -jar /Users/geraldmboowa/picard-tools-1.119/MarkDuplicates.jar INPUT=${sample}_sorted.bam OUTPUT=${sample}_sorted_dedup_reads.bam METRICS_FILE=${sample}_picard_info.txt REMOVE_DUPLICATES=true ASSUME_SORTED=true VALIDATION_STRINGENCY=LENIENT

samtools index ${sample}_sorted_dedup_reads.bam

java -jar /usr/local/bin/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /Volumes/BACKUP/Human_reference/human_g1k_v37.fasta -I ${sample}_sorted_dedup_reads.bam --known /Volumes/BACKUP/Human_reference/Know-snps-Indels/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz -o ${sample}_forIndelRealigner.intervals

java -jar /usr/local/bin/GenomeAnalysisTK.jar -T IndelRealigner -R /Volumes/BACKUP/Human_reference/human_g1k_v37.fasta -I ${sample}_sorted_dedup_reads.bam -known /Volumes/BACKUP/Human_reference/Know-snps-Indels/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz -targetIntervals ${sample}_forIndelRealigner.intervals -o ${sample}_Realigned_sorted_dedup_reads.bam

##Generates an index for the bam automatically and continues on

java -jar /usr/local/bin/GenomeAnalysisTK.jar -T BaseRecalibrator -R /Volumes/BACKUP/Human_reference/human_g1k_v37.fasta -I ${sample}_sorted_dedup_reads.bam -knownSites /Volumes/BACKUP/Human_reference/Know-snps-Indels/dbsnp.147.vcf.gz -o ${sample}_recal.table

java -jar /usr/local/bin/GenomeAnalysisTK.jar -T PrintReads -R /Volumes/BACKUP/Human_reference/human_g1k_v37.fasta -I ${sample}_Realigned_sorted_dedup_reads.bam -BQSR ${sample}_recal.table -o ${sample}_Re_calibrated_Realigned_sorted_dedup.bam

java -jar /usr/local/bin/GenomeAnalysisTK.jar -T HaplotypeCaller -R /Volumes/BACKUP/Human_reference/human_g1k_v37.fasta -I ${sample}_Re_calibrated_Realigned_sorted_dedup.bam -o ${sample}_Re_UG_calls.vcf

## Variant annotation using Annovar and selected databases

perl /usr/local/bin/annovar/convert2annovar.pl --includeinfo -format vcf4old ${sample}_Re_UG_calls.vcf > ${sample}_UG_calls.avinput

perl /usr/local/bin/annovar/table_annovar.pl ${sample}_UG_calls.avinput /usr/local/bin/annovar/humandb/ -buildver hg19 -out ${sample}_UG_calls_myanno -remove -protocol refGene,cytoBand,genomicSuperDups,snp138,esp6500siv2_all,ljb26_all,1000g2015aug_afr,1000g2015aug_eas,1000g2015aug_eur,avsift,clinvar_20180603,dbnsfp30a,icgc21,exac03,exac03nonpsych,gerp++elem,caddgt20 -operation g,r,r,f,f,f,f,f,f,f,f,f,f,f,f,f,f -nastring . -csvout

end=$SECONDS
echo "duration: $((end-start)) seconds."
done
exit

