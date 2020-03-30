#!/bin/bash
#Version 1.0
#tested on kali linux
#created by Luutu
#This is a program to align samples from luutu.txt with S.aureus. convert sam to bam, sort and index

#echo "Indexing reference genome" #Endeavor to index before you align

#bwa index S.aureus.fasta

#Align samples from luutu.txt to the indexed ref.gen
#for sample in `cat luutu.txt`
#do
#R1=${sample}_L001_R1_001_val_1.fq
#R2=${sample}_L001_R2_001_val_2.fq

#echo "Aligning $sample to indexed ref gen" #Use the bwa mem algorithm
#bwa mem S.aureus.fasta $R1 $R2 > ${sample}.sam
#echo "=============================================================="
#done
#echo "======================================================================================================================================="
#convert sam to bam
#echo "converting sam to bam"
#for sample in `ls *.sam`
#do
#echo "converting $sample to bam"
#samtools view -S -b $sample > ${sample}.bam
#echo "==============================================================="
#done

#echo "======================================================================================================================================"

#sorting bam
#for sample in `ls *.bam`
#do
#echo "sorting $sample"
#samtools sort -f $sample ${sample}_sorted.bam
#echo "==============================================================="
#done
#echo "======================================================================================================================================"

#index sorted bam
#for sample in `ls *sorted*`
#do
#echo "indexing $sample"
#samtools index $sample > ${sample}.bai
#echo "==================================================================="
#done
#echo "====================================================================================================================================="

#creating genotype liklelyhood
#for sample in `ls *sorted.bam`
#do
#echo "creating genotype likelyhood of $sample"
#bcftools mpileup -O b -o ${sample}.bcf -f S.aureus.fasta $sample
#echo "=================================================================="
#done
#echo "======================================================================================================================================="
#variant calling
#for sample in `ls *.bcf`
#do
#echo "Variant calling for $sample"
#bcftools call --ploidy 1 -m -v -o ${sample}.vcf $sample
#echo "=================================================================="
#done
#echo "===========================================done======================================================================================="
#bzip file
for sample in `ls *.vcf`
do
bgzip $sample
done

#index and make a consensus fasta file
for sample in `ls *gz`
do
#indexing
bcftools index $sample
#make a consensus
cat S.aureus.fasta | bcftools consensus $sample > ${sample}.fa
done

######################################################
# call variants
bcftools mpileup -Ou -f reference.fa alignments.bam | bcftools call -mv -Oz -o calls.vcf.gz
bcftools index calls.vcf.gz

# normalize indels
bcftools norm -f reference.fa calls.vcf.gz -Ob -o calls.norm.bcf

# filter adjacent indels within 5bp
bcftools filter --IndelGap 5 calls.norm.bcf -Ob -o calls.norm.flt-indels.bcf

#consesus11
cat reference.fa | bcftools consensus calls.vcf.gz > consensus.fa





