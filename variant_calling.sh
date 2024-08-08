#!/bin/bash

# Input parameters
sampleName=$1
sex=$2
ref=$3
bamFile=$4
diploidRegionX=$5
maskedRegionY=$6
max_jobs=$7
output_dir=$8

# Load chromosome names from reference index
mapfile -t CHROMOSOMES < <(awk '{print $1}' "$ref.fai" | grep -v -e "MT" -e "NW")

call_variants() {
    local ploidy=$1
    local chrom=$2
    local outputVCF=$3
    local region=$4
    local exclude_intervals=$5
    local exclude_arg=""
    if [ -n "$exclude_intervals" ]; then
        exclude_arg="--exclude-intervals $exclude_intervals"
    fi

    gatk HaplotypeCaller \
        --java-options "-Xmx32G -XX:+UseParallelGC -XX:ParallelGCThreads=8 -Djava.io.tmpdir=/dev/shm" \
        -R "$ref" \
        -I "$bamFile" \
        -O "$outputVCF" \
        $exclude_arg \
        -L "$region" \
        -ploidy "$ploidy" \
        -ERC GVCF \
        -pairHMM AVX_LOGLESS_CACHING \
        -A Coverage \
        -A DepthPerAlleleBySample \
        -A DepthPerSampleHC \
        -A InbreedingCoeff \
        -A MappingQualityRankSumTest \
        -A MappingQualityZero \
        -A QualByDepth \
        -A ReadPosRankSumTest \
        -A RMSMappingQuality \
        -A StrandBiasBySample \
        --native-pair-hmm-threads 8
}

current_jobs=0

for chrom in "${CHROMOSOMES[@]}"; do
    if [ "$sex" == "male" ] && [[ "$chrom" == *"chrX"* ]]; then
        call_variants 2 "$chrom" "$output_dir/diploid_${chrom}.g.vcf" "$chrom" "$diploidRegionX" &
        call_variants 1 "$chrom" "$output_dir/haploid_${chrom}.g.vcf" "$chrom" "$diploidRegionX" &
        current_jobs=$((current_jobs+2))
    elif [ "$sex" == "male" ] && [[ "$chrom" == *"chrY"* ]]; then
        call_variants 1 "$chrom" "$output_dir/${chrom}.g.vcf" "$chrom" "$maskedRegionY" &
        current_jobs=$((current_jobs+1))
    elif [ "$sex" == "female" ] && [[ "$chrom" == *"chrY"* ]]; then
        continue
    elif [ "$sex" == "female" ] && [[ "$chrom" == *"chrX"* ]]; then
        call_variants 2 "$chrom" "$output_dir/${chrom}.g.vcf" "$chrom" "" &
        current_jobs=$((current_jobs+1))
    else
        call_variants 2 "$chrom" "$output_dir/${chrom}.g.vcf" "$chrom" "" &
        current_jobs=$((current_jobs+1))
    fi

    if [ "$current_jobs" -ge "$max_jobs" ]; then
        wait -n
        current_jobs=$((current_jobs-1))
    fi
done
wait

cd "$output_dir"
vcf_files=''

for chrom in "${CHROMOSOMES[@]}"; do

    if [[ "$chrom" == *"chrY"* ]] && [ "$sex" == "female" ]; then
        continue
    fi

    if [[ "$chrom" == *"chrX"* ]] && [ "$sex" == "male" ]; then
        # Concatenate and sort chrX VCF files
        vcf-concat "diploid_${chrom}.g.vcf" "haploid_${chrom}.g.vcf" > "combined_${chrom}.g.vcf"
        vcf-sort "combined_${chrom}.g.vcf" > "${chrom}.g.vcf"
        gatk IndexFeatureFile -I "${chrom}.g.vcf"
    else
        vcf_file="${chrom}.g.vcf"
    fi
   
    if [ -e "$vcf_file" ]; then
        vcf_files+="-I ${vcf_file} "
    fi
done

echo "Variant calling completed for $sampleName."


