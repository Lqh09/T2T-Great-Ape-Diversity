#!/bin/bash
#SBATCH --job-name=SF2_T2T
#SBATCH --output=SF2_phased_conf_1k_%A_%a.out
#SBATCH --error=SF2_phased_conf_1k_%A_%a.err
#SBATCH --array=1-10
#SBATCH --time=336:00:00
#SBATCH --partition=sla-prio
#SBATCH --account=cdh5313_b
#SBATCH --mem=25gb


cd $SLURM_SUBMIT_DIR

input_dir=$1
output_dir=$2

populations=("bonobo" "bornean_orangutan" "central_chimpanzee" "eastern_chimpanzee" "eastern_lowland_gorilla" "mountain_gorilla" "nigerian_chimpanzee" "sumatran_orangutan" "western_chimpanzee" "western_lowland_gorilla")

# Get the current population from the array index for parallel analysis
pop_index=$((SLURM_ARRAY_TASK_ID - 1))
pop=${populations[$pop_index]}

for chr in $(seq 1 23)
do
/storage/home/ans6160/work/SF2/SweepFinder2 -lg 1000 ${input_dir}/${pop}_chr${chr}_in_phased_conf.sf background_SFS_phased_conf/${pop}_background_spec.txt ${output_dir}/${pop}_chr${chr}_out_phased_conf_1k_grid.sf
done
