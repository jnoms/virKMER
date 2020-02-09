#!/bin/bash

#SBATCH -t 0-1:00:0
#SBATCH -p priority
#SBATCH --mem=10GB
#SBATCH -c 2

module load gcc

#------------------------------------------------------------------------------#
#Defining usage and setting input
#------------------------------------------------------------------------------#
usage() {
        echo "
        This purpose of this file is to run kmer enrichment and pull reads from
        the experimental samples that contain kmers that are:
        1) Not present in the control samples and
        2) Present in the viral database

        Usage:
        $0
        -e <EXPERIMENTAL_GLOB>
          Glob to the experimental reads (fastq)
        -c <CONTROL_GLOB>
          Glob to the control reads (fastq) for in the READS_FILE.
        -o <OUTPUT_DIR>
          Directory to the enriched reads from each experimental file. The file
          names will be the same as the input, so put into a new directory...
        -k <KMER_SIZE>
          Size of the kmers to use for enrichment.
        -t <THREASHOLD>
          The number of experimental samples that need to have the kmer for it
          to be kept.

        (Optional)
        -d <GENOME_DATABASE_FA> [""]
          Path to a fasta containing a database. If this option is present, only
          kmers that are present in this database will be kept. This is a good
          place to add a viral genomic database.
        -T <THREADS> [1]
          Number of computing threads
        -L <LOW_COUNT> [2]
          Miniumum number of times a kmer must be present in a file for it to be
          considered.
        "
}

#If less than 3 options are input, show usage and exit script.
if [ $# -le 3 ] ; then
        usage
        exit 1
fi

#Setting input
while getopts e:c:o:k:t:d:T:L: option ; do
        case "${option}"
        in
                e) EXPERIMENTAL_GLOB=${OPTARG};;
                c) CONTROL_GLOB=${OPTARG};;
                o) OUTPUT_DIR=${OPTARG};;
                k) KMER_SIZE=${OPTARG};;
                t) THREASHOLD=${OPTARG};;
                d) GENOME_DATABASE_FA=${OPTARG};;
                T) THREADS=${OPTARG};;
                L) LOW_COUNT=${OPTARG};;
        esac
done

#------------------------------------------------------------------------------#
# Set default params
#------------------------------------------------------------------------------#
THREADS=${THREADS:-1}
LOW_COUNT=${LOW_COUNT:-2}

#------------------------------------------------------------------------------#
# Main
#------------------------------------------------------------------------------#

echo "
Starting kmer enrichment.
Input params are as follows:
EXPERIMENTAL_GLOB: $EXPERIMENTAL_GLOB
CONTROL_GLOB: $CONTROL_GLOB
OUTPUT_DIR: $OUTPUT_DIR
KMER_SIZE: $KMER_SIZE
THREASHOLD: $THREASHOLD
GENOME_DATABASE_FA: $GENOME_DATABASE_FA
THREADS: $THREADS
LOW_COUNT: $LOW_COUNT
"

# Find kmers in experimental and control files
for FILE in $EXPERIMENTAL_GLOB ; do
  $VKMER/bin/bash/jellyfish.sh \
    -i $FILE \
    -o experimental_kmers/$(basename ${FILE%.fastq}).kmers \
    -k $KMER_SIZE \
    -t $THREADS \
    -L $LOW_COUNT
done

for FILE in $CONTROL_GLOB ; do
  $VKMER/bin/bash/jellyfish.sh \
    -i $FILE \
    -o control_kmers/$(basename ${FILE%.fastq}).kmers \
    -k $KMER_SIZE \
    -t $THREADS \
    -L $LOW_COUNT
done

# Get enriched kmers between experimental and control
python $VKMER/bin/python/get_enriched_kmers.py \
-e "experimental_kmers/*kmers" \
-c "control_kmers/*kmers" \
-o experimental_control_enriched.kmers \
-t $THREASHOLD

# If GENOME_DATABASE is entered, do that filtration
if [[ $GENOME_DATABASE_FA != '' ]] ; then

  # first get genome database kmers
  $VKMER/bin/bash/jellyfish.sh \
    -i $GENOME_DATABASE_FA  \
    -o genome_database.kmers \
    -k $KMER_SIZE \
    -t $THREADS \
    -L $LOW_COUNT

  # then get the common ones with the current enriched kmers
  python $VKMER/bin/python/get_common_kmers.py \
  -1 experimental_control_enriched.kmers \
  -2 genome_database.kmers \
  -o final_enriched.kmers

else
    # Otherwise, just set the final_enriched.kmers
    cp experimental_control_enriched.kmers final_enriched.kmers

fi

echo "There are $(wc -l final_enriched.kmers) enriched kmers."

# Extract the kmer-containing reads
for FILE in $EXPERIMENTAL_GLOB ; do
    $VKMER/bin/bash/get_reads_containing_kmers.sh \
    -r $FILE \
    -k final_enriched.kmers \
    -o $OUTPUT_DIR/$(basename $FILE)
done

echo "Finished"
