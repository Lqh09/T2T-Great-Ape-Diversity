#!/bin/bash
  

# Input parameters
ref="$1"
ref_idx="$2"
fastq1="$3"
fastq2="$4"
sample_name="$5"
threads="$6"
memory="$7"
output_dir="$8"

mkdir -p "$output_dir"

# Run BWA MEM with the indexed reference
if [[ -f "$fastq2" ]]; then
    bwa mem -Y -K 100000000 -t "$threads" -R "@RG\tID:$sample_name\tPL:illumina\tPM:Unknown\tLB:$sample_name\tDS:$ref\tSM:$sample_name\tCN:NYGenome\tPU:1" "$ref_idx" "$fastq1" "$fastq2" | \
    samtools view -Shb -o "$output_dir/${sample_name}.bam" -
else
    bwa mem -Y -K 100000000 -t "$threads" -R "@RG\tID:$sample_name\tPL:illumina\tPM:Unknown\tLB:$sample_name\tDS:$ref\tSM:$sample_name\tCN:NYGenome\tPU:1" "$ref_idx" "$fastq1" | \
    samtools view -Shb -o "$output_dir/${sample_name}.bam" -
fi

samtools sort -m "$memory" -@ "$threads" -o "$output_dir/${sample_name}.sort.bam" "$output_dir/${sample_name}.bam"
rm "$output_dir/${sample_name}.bam"

java -jar /data/mschatz1/qiuhuili/bin/picard.jar MarkDuplicates \
    M="$output_dir/${sample_name}_metrics.txt" \
    I="$output_dir/${sample_name}.sort.bam" \
    O="$output_dir/${sample_name}.dedup.bam"


rm "$output_dir/${sample_name}.sort.bam"

# Index the final BAM file
samtools index -@ "$threads" "$output_dir/${sample_name}.dedup.bam"

echo "Processing completed. Output files are in $output_dir"

