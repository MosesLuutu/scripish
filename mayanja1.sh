#!/bin/bash
#Extract all the fastq reads
echo "Running fastq-dump"
for i in "$@"
do
echo "Running fastq-dump for $i"
fastq-dump --split-3 --gzip $i
echo "===================Done fastq-dump for $i==================================================="
done
echo "======================DONE WITH FASTQ-DUMP==================================================="
#Do fastqc
echo "Running fastqc NOW"
for i in `ls *gz`
do
echo "Running fastqc for $i"
fastqc $i
echo "==================================Done with fastqc for $i============================================"
done
echo "===================DONE WITH FASTQC OF ALL SAMPLES====================================================="
#Do mykrobe
echo "Running mykrobe on the samples NOW"
for i in "$@"
do
echo "Running mykrobe for $i"
mykrobe predict $i tb -1 ${i}_1.fastq.gz ${i}_2.fastq.gz --format csv --output ${i}.csv
echo "===============================Done with mykrobe for $i============================================"
done
echo "=========================================DONE WITH MYKROBE FOR ALL SAMPLES============================="
#convert into a sensible output
echo "Converting csv to tab separated file"
for i in `ls *.csv`
do
echo "Converting $i"
cut -d, -f1-3,12,13 $i | sed 's/,/\t\t/g' | sed 's/"//g' | sed '1d' | \
sed '1iSAMPLE ID\t\t  DRUG\t\tSUSCEPTIBILITY\t\tSPECIES\t\tLINEAGE' > ${i}.tab
echo "==========================finished converting $i==========================================================="
done
echo "============================DONE WITH CONVERSION============================================================"
#convert tab files to pdfs
