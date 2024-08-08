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


### Selective Sweep Scans
The SF2 file uses SweepFinder2. The T2T_lassip file uses the saltiLASSI method.


### Haplotype phasing of Primate Genomes

The pipeline applied for population-based haplotype phasing is in the `phasing` directory.
