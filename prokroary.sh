#!/bin/bash
#annotating using prokka
echo "annotating using prokka"
for sample in `ls *.fa`
do
prokka --outdir mydir --prefix ${sample} $sample
echo "=================================================================="
#done
#performing pan_genome analysis
echo "rrrrroooooaaaaarrrrryyyy"
roary mydir/*.gff
echo "=================================================================="
#done
#organising
mkdir GFF
mkdir csv
cp mydir/*.gff mydir/GFF
cp mydir/*.csv mydir/csv
