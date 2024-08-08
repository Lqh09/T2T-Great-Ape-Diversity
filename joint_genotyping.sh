#!/bin/bash

# Input parameters
GVCF_INFO_FILE=$1
OUTPUT_FOLDER=$2
REF=$3
REF_FEMALE=$4
REF_MALE=$5
DIPLOID_REGION_X=$6
MASKED_REGION_Y=$7
MAX_CONCURRENT_JOBS=$8

mkdir -p $OUTPUT_FOLDER
mkdir -p $OUTPUT_FOLDER/tmp

# Define autosomes and sex chromosomes
AUTOSOMES=($(seq -f "chr%g" 1 22))
SEX_CHROMOSOMES=("chrX" "chrY")

# Read sample information from file
declare -A SAMPLES
declare -A GVCF_PATHS
while IFS=$'\t' read -r name sex path; do
  SAMPLES["$name"]=$sex
  GVCF_PATHS["$name"]=$path
done < "$GVCF_INFO_FILE"

process_chromosome() {
    local chrom=$1
    local sex=$2
    local ploidy=$3
    local ref=$4
    local exclude_intervals=$5
    local GVCF_LIST=""

    for sample in "${!SAMPLES[@]}"; do
        if [ "${SAMPLES[$sample]}" == "$sex" ] || [ -z "$sex" ]; then
            GVCF_LIST+="-V ${GVCF_PATHS[$sample]}/${chrom}.g.vcf "
        fi
    done

    if [ -z "$GVCF_LIST" ]; then
        return
    fi

    if [[ "$chrom" == "chrX" ]] && [ -n "$exclude_intervals" ]; then
        # Haploid region
        workspace_haploid="${OUTPUT_FOLDER}/genomicsDB_${chrom}_${sex}_haploid"
        gatk --java-options "-Xmx30G -XX:+UseParallelGC -XX:ParallelGCThreads=4 -Djava.io.tmpdir=/dev/shm" GenomicsDBImport \
            $GVCF_LIST \
            --genomicsdb-shared-posixfs-optimizations true \
            --batch-size 50 \
            -R $ref  \
            --reader-threads  4 \
            --genomicsdb-workspace-path "${workspace_haploid}" \
            -L ${chrom} --exclude-intervals $exclude_intervals  && \

        gatk --java-options "-Xmx30G" GenotypeGVCFs \
            -R $ref \
            -L ${chrom} --exclude-intervals $exclude_intervals \
            -V gendb://${workspace_haploid} \
            -O ${OUTPUT_FOLDER}/haploid_${chrom}_${sex}.vcf.gz \
            --tmp-dir ${OUTPUT_FOLDER}/tmp \
            --ploidy $ploidy

	rm -rf "${workspace_haploid}"

        # Diploid region
        workspace_diploid="${OUTPUT_FOLDER}/genomicsDB_${chrom}_${sex}_diploid"
        gatk --java-options "-Xmx30G -XX:+UseParallelGC -XX:ParallelGCThreads=4 -Djava.io.tmpdir=/dev/shm" GenomicsDBImport \
            $GVCF_LIST \
            --genomicsdb-shared-posixfs-optimizations true \
            --batch-size 50 \
            -R $ref \
            --reader-threads  4 \
            --genomicsdb-workspace-path "${workspace_diploid}" \
            -L $exclude_intervals  && \

        gatk --java-options "-Xmx30g" GenotypeGVCFs \
            -R $ref \
            -L $exclude_intervals \
            -V gendb://${workspace_diploid} \
            -O ${OUTPUT_FOLDER}/diploid_${chrom}_${sex}.vcf.gz \
            --tmp-dir ${OUTPUT_FOLDER}/tmp \
            --ploidy 2

	rm -rf "${workspace_diploid}"

    elif [[ "$chrom" == "chrY" ]] && [ -n "$exclude_intervals" ]; then
        workspace="${OUTPUT_FOLDER}/genomicsDB_${chrom}_${sex}"
        gatk --java-options "-Xmx30G -XX:+UseParallelGC -XX:ParallelGCThreads=4 -Djava.io.tmpdir=/dev/shm" GenomicsDBImport \
            $GVCF_LIST \
            --genomicsdb-shared-posixfs-optimizations true \
            --batch-size 50 \
            -R $ref \
            --reader-threads  5 \
            --genomicsdb-workspace-path "${workspace}" \
            -L ${chrom} --exclude-intervals $exclude_intervals  && \

        gatk --java-options "-Xmx30g" GenotypeGVCFs \
            -R $ref \
            -L ${chrom} --exclude-intervals $exclude_intervals \
            -V gendb://${workspace} \
            -O ${OUTPUT_FOLDER}/${chrom}_${sex}.vcf.gz \
            --tmp-dir ${OUTPUT_FOLDER}/tmp \
            --ploidy $ploidy

	rm -rf "${workspace}"

    else
        workspace="${OUTPUT_FOLDER}/genomicsDB_${chrom}_${sex}"
        gatk --java-options "-Xmx30G -XX:+UseParallelGC -XX:ParallelGCThreads=4 -Djava.io.tmpdir=/dev/shm"  GenomicsDBImport \
            $GVCF_LIST \
            --genomicsdb-shared-posixfs-optimizations true \
            --batch-size 50 \
            -R $ref \
            --reader-threads  4 \
            --genomicsdb-workspace-path "${workspace}" \
            -L ${chrom}   && \
	
	if [ -n "$sex" ]; then
	    output_file_name="${chrom}_${sex}"
	else
	    output_file_name="${chrom}"
        fi

        gatk --java-options "-Xmx30g" GenotypeGVCFs \
            -R $ref \
            -L ${chrom}  \
            -V gendb://${workspace} \
            -O ${OUTPUT_FOLDER}/${output_file_name}.vcf.gz \
            --tmp-dir ${OUTPUT_FOLDER}/tmp \
            --ploidy $ploidy 

	rm -rf "${workspace}"
    fi
}

# Initialize current_jobs to 0
current_jobs=0

# Process autosomes
for chrom in "${AUTOSOMES[@]}"; do
    process_chromosome $chrom "" 2 $REF "" &
    current_jobs=$((current_jobs+1))
    if (( current_jobs >= MAX_CONCURRENT_JOBS )); then
        wait -n
        current_jobs=$((current_jobs-1))
    fi
done

# Process sex chromosomes
process_chromosome "chrX" "male" 1 $REF_MALE "$DIPLOID_REGION_X"
process_chromosome "chrY" "male" 1 $REF_MALE "$MASKED_REGION_Y"
process_chromosome "chrX" "female" 2 $REF_FEMALE ""


