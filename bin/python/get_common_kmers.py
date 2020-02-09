#!/usr/bin/env python3
import argparse
import pathlib
import os

def read_in_kmers(infile):
    kmers = set()
    with open(infile) as infile_handle:
        for line in infile_handle:
            if line == "":
                continue

            if line.startswith(">"):
                continue

            kmers.add(line.rstrip("\n"))

    return kmers

def write_output(msg ,outfile):

    # Generate the output directories if necessary
    out_dir = os.path.dirname(outfile)
    pathlib.Path(out_dir).mkdir(parents=True, exist_ok=True)

    # write output
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

    # Take intersection and collapse
    intersection = kmers1.intersection(kmers2)
    intersection = "\n".join(intersection)

    # Produce output
    write_output(intersection, output_file)


if __name__ == '__main__':
    main()
