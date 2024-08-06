#!/bin/bash
#SBATCH --job-name=T2T_phased
#SBATCH --output=T2T_unphased_v1.2.0_%A_%a.out
#SBATCH --error=T2T_unphased_v1.2.0_%A_%a.err
#SBATCH --array=1-4
#SBATCH --time=48:00:00
#SBATCH --partition=open
#SBATCH --mem=30gb

cd $SLURM_SUBMIT_DIR

input_dir=$1
output_dir=$2

populations=("bonobo" "mountain_gorilla" "western_chimpanzee" "western_lowland_gorilla")
#populations=("bornean_orangutan" "eastern_lowland_gorilla" "nigerian_chimpanzee" "sumatran_orangutan") #these taxa had n < 10, so k was set to 5 in the first step

# Get the current population from the array index for parallel runs
pop_index=$((SLURM_ARRAY_TASK_ID - 1))
pop=${populations[$pop_index]}

#first step of salitLASSI, loop through each chromosome
#generates spectra files for each chromosome
for chr in $(seq 1 23)
do
/storage/home/ans6160/work/lassip-master-v1.2.0/src/lassip --vcf ${input_dir}/${pop}_phased_conf_chr${chr}.vcf.gz --pop variant_calling_v2/${pop}_popID.txt --unphased \
--hapstats --calc-spec --winsize 201 --winstep 100 --salti --out ${output_dir}/${pop}_chr${chr}_201win_100step_unphased_conf
done

#second step calculate average whole genome HFS
/storage/home/ans6160/work/lassip-master-v1.2.0/src/lassip --spectra ${input_dir}/${pop}_chr*_201win_100step_unphased_conf.${pop}.lassip.mlg.spectra.gz --avg-spec \
--out ${output_dir}/${pop}_201win_100step_unphased_avg_spec

#third step calculate L stat
for chr in $(seq 1 23)
do
/storage/home/ans6160/work/lassip-master-v1.2.0/src/lassip --spectra ${input_dir}/${pop}_chr${chr}_201win_100step_unphased_conf.${pop}.lassip.mlg.spectra.gz --salti \
--null-spec unphased_background_HFS/${pop}_201win_100step_unphased_avg_spec.lassip.null.spectra.gz --out ${output_dir}/${pop}_chr${chr}_201win_100step_unphased_conf
done



