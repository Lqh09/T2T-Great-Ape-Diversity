# Haplotype phasing for T2T Primate Variant Datasets

This pipeline conducts internal population phasing for assorted datasets using pre-existing software.

This iteration specifically used BEAGLE4 for non-reference based phasing.

For questions, contact: Arjun Biddanda (@aabiddanda)

## Step 1: Install Environment

Install Snakemake and the baseline environment using [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html):

```
conda env create -f environment.yaml
```

You may also use [mamba](https://github.com/mamba-org/mamba) for faster dependency management.

## Step 2: Execute workflow

Activate the conda environment:
```
    conda activate hap-phasing
```
Test your configuration by performing a dry-run via
```
    snakemake --use-conda -n
```
Execute the workflow locally via
```
    snakemake --use-conda --cores $N
```
using `$N` cores or run it in a cluster environment via
```
    snakemake --use-conda --cluster qsub --jobs 100
```
See the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executable.html) for further details.

