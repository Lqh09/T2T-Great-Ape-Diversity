# T2T-Great-Ape-Diversity
## Project Overview
This project utilizes Telomere-to-Telomere (T2T) assembly reference genomes to perform comprehensive genomic analyses for five great ape species: gorillas, chimpanzees, bonobos, Sumatran orangutans, and Bornean orangutans. Our findings reveal the great potential of T2T reference genomes in facilitating more accurate and detailed genomic and functional analyses of great ape species.  

### Short-Read Mapping and Variant Calling
#### Preparation
- **Reference Genome**: Required for mapping reads.
- **Paired-End Reads**: From the sample to be analyzed.
- **PAR Regions**: Pseudoautosomal regions (PARs) are specific regions on chromosomes X and Y。
- **Karyotype-Specific References**: For XX and XY individuals, refer to the published masking method by Rhie et al. (2023).

#### Alignment
Align reads from XX and XY samples to their respective masked reference genomes.

##### Code Example
```bash
python align.py -r [reference genome] -i [index] -f1 [FASTQ1] -f2 [FASTQ2] -s [sample name] -o [output dir] -t [threads] -m [memory]
```
#### Variant Detection
##### Step 1: Initial Variant Calling for Each Sample
```bash
python variant_calling.py -s [sample name] -x [sex] -r [reference genome] -b [BAM file] -d [chrX region] -m [chrY region] -o [output dir] -j [jobs]
```
##### Step 2: Joint Genotyping
```bash
python joint_genotypeing.py -i [GVCF info file] -o [output dir] -f [reference genome] -XX_f [female ref] -XY_f [male ref] -d [chrX PAR region] -m [chrY PAR region] -j [jobs]
```
##### Step 3: Final Variant Callset
Apply GATK's hard-filtering parameters to refine results:
SNPs: -filter "QD < 2.0 || QUAL < 30.0 || SOR > 3.0 || FS > 60.0 || MQ < 40.0 || GQ < 20"
Indels: -filter "QD < 2.0 || QUAL < 30.0 || FS > 200.0 || GQ < 20


### Selective Sweep Scans
The SF2 file uses SweepFinder2. The T2T_lassip file uses the saltiLASSI method.


### Haplotype phasing of Primate Genomes

The pipeline applied for population-based haplotype phasing is in the `phasing` directory.
