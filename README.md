# xvcfview

This workflow provides the full power of [bcftools view](http://samtools.github.io/bcftools/bcftools.html#view) to subset, subsample, and filter VCF files.

## input

All input files are referenced with either gs:// or drs:// URIs.


| parameter | required | default | description |
| --------- | -------- | :---------: | ----------- |
| `input_vcf` | required | | Input VCF file. |
| `input_vcf_index` | optional | | VCF index file. If omitted, an index is created during execution. Instructions for creating index files are [here](http://samtools.github.io/bcftools/bcftools.html#index). |
| `samples` | optional | | File of samples to be included in the output VCF. There should one sample per line. Additional information is [here](http://samtools.github.io/bcftools/bcftools.html#common_options). |
| `regions` | optional | | File of regions to be included in the output VCF. The file should contain tab separated columns of chromosome (e.g. 'chr15'), start position, and optionally end position. Additional information is [here](http://samtools.github.io/bcftools/bcftools.html#common_options). |
| `view_options` | optional | `-Oz` | Additional parameters to pass to the [bcftools view](http://samtools.github.io/bcftools/bcftools.html#view) command. If modified, `view_options` should typically include `-Oz` to produce a gzipped output VCF. |
| `filters` | optional | | Filter arguments to pass into [bcftools view](http://samtools.github.io/bcftools/bcftools.html#view). Filters will be applied in a separate, subsequent, call to `bcftools view`. |
| `output_filename` | optional | `output.vcf.gz` | Name of the output vcf file. |
| `cpu` | optional | `8` | Number of CPU cores. |
| `memory` | optional | `64` | Amount of RAM in GB |
| `preemptible` | optional | `0` | Whether to use preemptible instances, which are cheaper but my be revoked during execution. |
