import subprocess
import argparse
import os

def run_command(command):
    """Run a system command."""
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    if process.returncode != 0:
        print("Command failed.")

def main():
    parser = argparse.ArgumentParser(description="Run variant calling pipeline.")
    parser.add_argument("-s", "--sampleName", type=str, required=True, help="Sample name")
    parser.add_argument("-x", "--sex", type=str, required=True, choices=["male", "female"], help="Sex of the sample")
    parser.add_argument("-r", "--ref", type=str, required=True, help="Path to the reference genome")
    parser.add_argument("-b", "--bamFile", type=str, required=True, help="Path to the input BAM or CRAM file")
    parser.add_argument("-d", "--diploidRegionX", type=str, required=True, help="Diploid region for chrX")
    parser.add_argument("-m", "--maskedRegionY", type=str, required=True, help="Masked region for chrY")
    parser.add_argument("-j", "--maxJobs", type=int, default=4, help="Maximum number of concurrent jobs (default: 4)")
    parser.add_argument("-o", "--outputDir", type=str, required=True, help="Output directory for results")

    args = parser.parse_args()

    # Ensure the output directory exists
    output_dir = os.path.join(args.outputDir, args.sampleName)
    os.makedirs(output_dir, exist_ok=True)

    command = (
        f"bash variant_calling.sh {args.sampleName} {args.sex} "
        f"{args.ref} {args.bamFile} {args.diploidRegionX} {args.maskedRegionY} "
        f"{args.maxJobs} {output_dir}"
    )
    run_command(command)

if __name__ == "__main__":
    main()


