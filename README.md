# T2T-Great-Ape-Diversity
## Project Overview
This project utilizes Telomere-to-Telomere (T2T) assembly reference genomes to perform comprehensive genomic analyses for five great ape species: gorillas, chimpanzees, bonobos, Sumatran orangutans, and Bornean orangutans. Our findings reveal the great potential of T2T reference genomes in facilitating more accurate and detailed genomic and functional analyses of great ape species.  

### Short-Read Mapping and Variant Calling
#### Preparation
- **Reference Genome**: Required for mapping reads.
- **Paired-End Reads**: From the sample to be analyzed, refer to detailed sample information in [Makova et al. (2024)](https://www.nature.com/articles/s41586-024-07473-2).
- **PAR Regions**: Pseudoautosomal regions (PARs) are specific regions on chromosomes X and Y。
- **Karyotype-Specific References**: For XX and XY individuals, refer to the published masking method by by [Rhie et al. (2023)](https://www.nature.com/articles/s41586-023-06457-y). 

#### Alignment
Align reads from XX and XY samples to their respective masked reference genomes.
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
python joint_genotyping.py -i [GVCF info file] -o [output dir] -f [reference genome] -XX_f [female ref] -XY_f [male ref] -d [chrX PAR region] -m [chrY PAR region] -j [jobs]
```
##### Step 3: Final Variant Callset
Apply GATK's hard-filtering parameters to refine results:
```bash
# Apply filters for SNPs
gatk VariantFiltration  -R [reference genome]  -V [input.vcf]  --filter-expression "QD < 2.0 || QUAL < 30.0 || SOR > 3.0 || FS > 60.0 || MQ < 40.0"   --filter-name "SNP_FILTER"   -O [filtered.vcf]
# Apply filters for Indels
gatk VariantFiltration   -R [reference genome]  -V [input.vcf]  --filter-expression "QD < 2.0 || QUAL < 30.0 || FS > 200.0"   --filter-name "INDEL_FILTER"  -O [filtered.vcf]
```
Ensure all variants have a genotype quality (GQ) no less than 20 to generate the final VCF file.

### Haplotype phasing of Primate Genomes
The pipeline applied for population-based haplotype phasing is in the `phasing` directory.

### Selective Sweep Scans
The SF2 file uses SweepFinder2. The T2T_lassip file uses the saltiLASSI method.

