import subprocess
import argparse

def run_command(command):
    """Run a system command."""
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    if process.returncode != 0:
        print("Process failed.")

def main():
    parser = argparse.ArgumentParser(description="Run GenomicsDB and GenotypeGVCFs pipeline.")
    parser.add_argument("-i", "--gvcfInfoFile", type=str, required=True, help="File with sample names, sex, and folder paths of GVCF files")
    parser.add_argument("-o", "--outputFolder", type=str, required=True, help="Output directory for results")
    parser.add_argument("-f", "--ref", type=str, required=True, help="Path to the reference genome")
    parser.add_argument("-XX_f", "--ref_female", type=str, required=True, help="Path to the reference genome for female")
    parser.add_argument("-XY_f", "--ref_male", type=str, required=True, help="Path to the reference genome for male")
    parser.add_argument("-d", "--diploidRegionX", type=str, required=True, help="Diploid region for chrX")
    parser.add_argument("-m", "--maskedRegionY", type=str, required=True, help="Masked region for chrY")
    parser.add_argument("-j", "--maxJobs", type=int, default=4, help="Maximum number of concurrent jobs (default: 4)")

    args = parser.parse_args()

    command = (
        f"bash joint_variant_calling.sh {args.gvcfInfoFile} {args.outputFolder} {args.ref} "
        f"{args.ref_female} {args.ref_male} {args.diploidRegionX} {args.maskedRegionY} {args.maxJobs}"
    )
    run_command(command)

if __name__ == "__main__":
    main()


