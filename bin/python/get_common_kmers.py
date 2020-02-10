#!/usr/bin/env python3
import argparse
import pathlib
import os
from Bio.Seq import Seq

def read_in_kmers(infile):
    print("Reading in {}".format(infile))
    kmers = set()
    with open(infile) as infile_handle:
        for line in infile_handle:
            if line == "":
                continue

            if line.startswith(">"):
                continue

            kmers.add(line.rstrip("\n"))

    return kmers

def add_reverse_complement_to_set(input_set):
    output_set = input_set

    for kmer in input_set:
        rev_comp = str(Seq(kmer).reverse_complement())
        output_set.add(rev_comp)

    return output_set

def write_output(msg ,outfile):

    # Generate the output directories if necessary
    out_dir = os.path.dirname(outfile)
    pathlib.Path(out_dir).mkdir(parents=True, exist_ok=True)

    # write output
    print("Writing common kmers to {}".format(outfile))
    with open(outfile, "w") as outfile_handle:
         outfile_handle.write(msg)


def main():
    #--------------------------------------------------------------------------#
    #Take inputs
    #--------------------------------------------------------------------------#
    parser = argparse.ArgumentParser(description="""
            The purpose of this script is to return the kmers present in both of the
            two input kmer files. Input files must have one kmer per line. If
            the input file is fasta that's also okay, because it will skip lines
            starting with '>'.
            """)

    # Required arguments
    parser.add_argument(
        '-1',
        '--input_one',
        type=str,
        required=True,
        help='''
        Path to the first input kmer file. One kmer per line, fasta format okay
        '''
    )
    parser.add_argument(
        '-2',
        '--input_two',
        type=str,
        required=True,
        help='''
        Path to the second input kmer file. One kmer per line, fasta format okay
        '''
    )
    parser.add_argument(
        '-o',
        '--output_file',
        type=str,
        required=True,
        help='''
        Path to the output file containing kmers that are present in both files.
        Will be just one kmer per line, not fasta format.
        '''
    )

    args = parser.parse_args()

    # Define input variables
    input_one = args.input_one
    input_two = args.input_two
    output_file = args.output_file

    #--------------------------------------------------------------------------#
    # Main
    #--------------------------------------------------------------------------#

    # Read in kmers
    kmers1 = read_in_kmers(input_one)
    kmers2 = read_in_kmers(input_two)

    # Take intersection
    intersection = kmers1.intersection(kmers2)

    # Make sure all reverse complements are also kept
    intersection = add_reverse_complement_to_set(intersection)

    # Collapse to string
    intersection = "\n".join(intersection)

    # Make sure all reverse complements are also kept
    intersection = add_reverse_complement_to_set(intersection)

    # Produce output
    write_output(intersection, output_file)


if __name__ == '__main__':
    main()
