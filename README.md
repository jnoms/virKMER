# virKMER
viral KMER enrichment - Used to enrich viral reads in an input dataset.

# Description
The purpose of this package is to find kmers that are present in a set of "experimental" samples and absent in a set of "control" samples. In addition, you can also mandate that the kmer be present in a specified database fasta. For example, adding a viral database fasta will keep only kmers that are present at least once in some viral genome. 

Reads in the experimental samples that have an enriched kmer are output to the output directory.

In test runs, this procedure is capable of causing a massive enrichment of viral reads in input files. For example, when run on several Merkel cell carcinoma samples, using cervical cancer samples as control samples, and using the refseq viral genome database that lacks Merkel Cell polyomavirus as the database fasta, this script increases Merkel cell polyomavirus reads from about 1% abundance (~3000 viral reads in ~300,000 total reads) in the input samples to >90% abundance (484 viral reads in 518 total reads) in the output samples. The only caveat is there was a ~90% loss in total viral reads. 

# Quickstart
```
$VKMER/virKMER.sh \
-e "experimental/\*fastq" \
-c "control/\*fastq" \
-o experimental_enriched_fastqs \
-k <kmer size> \
-t <# of experimental samples that must have kmer> \
-d <viral database in fasta> \
-T <num computing threads>
```
