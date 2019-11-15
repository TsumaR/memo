#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -e log
#$ -o log
#$ -pe def_slot 4
#$ -l s_vmem=16G,mem_req=16G
#$ -l os7
#$ -t 1-3:1

source activate atac_seq
source /home/myne812/setenv/fastqc.sh
source /home/myne812/setenv/star.sh
source /home/myne812/setenv/samtools.sh
source /home/myne812/setenv/homer.sh
source /home/myne812/setenv/bedtools.sh

#ディレクトリ
qc_dir=../result/qcreport
cln_dir=../result/cln_data

#file
adapter=/home/myne812/packages/Trimmomatic-0.39/adapters/NexteraPE-PE.fa
fasta=/home/myne812/data/index/human/hg38.fa
gtf=/home/myne812/data/index/human/Homo_sapiens.GRCh38.98.gtf
star_index=/home/myne812/data/index/human/star_index
annotate=annotatePeaks.pl
bed2pos=bed2pos.pl

#スクリプト
trimmomatic=/home/myne812/packages/Trimmomatic-0.39/trimmomatic-0.39.jar
picard=/usr/local/package/picard/2.18.16/picard.jar
fastqc=fastqc
STAR=STAR
macs2=macs2
samtools=samtools
bedtools=bedtools

cpu=4
seqid_lst=(14_4 20_4 07_4)
species=hs

index=$(( ${SGE_TASK_ID} - 1 ))
id=${seqid_lst[$index]}

if test $id!='summary' ; then
  cd $id
  
  #file depending on id
  cln1=cln1_${id}.fastq
  cln2=cln2_${id}.fastq
  uncln1=uncln1_${id}.fastq.gz
  uncln2=uncln2_${id}.fastq.gz
  bam=${id}.bam
  ddup_bam=${id}_remove_dup.bam
  MT_bam=${id}_remove_M.bam
  Y_bam=${id}_remove_Y.bam
  cln_bam=cln_${id}.bam
  cln_bed=${id}.bed
  peak=${id}_peaks.narrowPeak
  an_peak=${id}_peak.txt

  #trimming
  java -jar $trimmomatic \
    PE -phred33 -threads $cpu \
    -trimlog $qc_dir/${id}_log.txt \
    ${id}_R1.fastq.gz \
    ${id}_R2.fastq.gz \
    $cln1 $uncln1 \
    $cln2 $uncln2 \
    ILLUMINACLIP:$adapter:2:30:10 \
    LEADING:20 \
    TRAILING:20 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36

  #qc
  $fastqc -o $qc_dir $cln1
  $fastqc -o $qc_dir $cln2
  $fastqc -o $qc_dir ${id}_R1.fastq.gz
  $fastqc -o $qc_dir ${id}_R2.fastq.gz

  #mapping
  $STAR --runThreadN $cpu \
    --genomeDir $star_index \
    --readFilesIn $cln1 $cln2 \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix $bam

  #picardとかでduplicateを除去する必要がある？
  #omni_atacでもdenovo論文でもやってるからやっておく 

  java -jar $picard MarkDuplicates \
    REMOVE_DUPLICATES=true \
    I=${id}.bamAligned.sortedByCoord.out.bam \
    M=${id}_dupl.bam \
    O=$ddup_bam

  $samtools view -h -F4 $ddup_bam | grep -v chrM | $samtools view -b > $MT_bam 
  $samtools view -h -F4 $MT_bam | grep -v chrY | $samtools view -b > $cln_bam
  $samtools sort -o $cln_bam $cln_bam
  $samtools index $cln_bam  
  
  #peak call

  $macs2 callpeak \
    -t $cln_bam \
    -n $id \
    -f BAMPE \
    -g $species \
    --nomodel \
    --nolambda \
    --keep-dup all \
    --call-summits
   
  #annotation to peak
  $annotate ${id}_peaks.narrowPeak hg38 > $an_peak 

  #venn diagram
  #bedtools21 with either the '-v' (unique) and the '-u' (shared) options.

else
  cd $qcdir
  $multiqc .
fi
