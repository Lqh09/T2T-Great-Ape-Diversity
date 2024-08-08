import subprocess
import argparse

def run_command(command):
    """Run a system command."""
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    if process.returncode != 0:
        print("Process failed.")

def main():
    parser = argparse.ArgumentParser(description="Align to reference genome.")
    parser.add_argument("-r", "--ref_genome", type=str, required=True, help="Path to the reference genome")
    parser.add_argument("-i", "--ref_idx", type=str, required=True, help="Path to the reference index files")
    parser.add_argument("-f1", "--fastq1", type=str, required=True, help="Path to the FASTQ1 file")
    parser.add_argument("-f2", "--fastq2", type=str, required=True, help="Path to the FASTQ2 file")
    parser.add_argument("-s", "--sample_name", type=str, required=True, help="Sample name")
    parser.add_argument("-o", "--output_dir", type=str, required=True, help="Output directory")
    parser.add_argument("-t", "--threads", type=int, default=4, help="Number of threads")
    parser.add_argument("-m", "--memory", type=str, default="4G", help="Memory setting")

    args = parser.parse_args()

    command = (
        f"bash align.sh {args.ref_genome} {args.ref_idx} {args.fastq1} "
        f"{args.fastq2} {args.sample_name} {args.threads} {args.memory} {args.output_dir}"
    )
    run_command(command)

if __name__ == "__main__":
    main()


