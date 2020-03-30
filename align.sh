#!/bin/bash

echo "index the reference"

bwa index Vibro_sequence.fasta

echo "align using bwa"

bwa mem Vibro_sequence.fasta Sample36_1_val_1.fq Sample36_2_val_2.fq > Sample36.sam

echo "convert sam file to bam file using samtools"

samtools view -S -b Sample36.sam > Sample36.bam

echo "sort the bam file using samtools"

samtools sort Sample36.bam -o Sample36_sorted.bam

echo "index the sorted bam using samtools"

samtools index -b Sample36_sorted.bam




