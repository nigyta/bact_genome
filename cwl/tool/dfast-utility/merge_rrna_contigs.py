#!/bin/env python

import sys
import argparse
from logging import getLogger, StreamHandler, Formatter, DEBUG
from Bio import SeqIO


def main(gbk_file_base, gbk_file_repeat, out_genome_fasta):

    R = [r for r in SeqIO.parse(gbk_file_base, "genbank")]
    S = set(["16S ribosomal RNA", "23S ribosomal RNA"])

    for r in R:
        for f in r.features:
            product = f.qualifiers.get("product", [""])[0]
            if product in S:
                S.remove(product)        

    num = len(R)
    for r in SeqIO.parse(gbk_file_repeat, "genbank"):
        for f in r.features:
            product = f.qualifiers.get("product", [""])[0]
            if product in S:
                num += 1
                r.id = "additional" + str(num)
                logger.info(f'{product} found in {gbk_file_repeat}. "{r.id}" is added to {out_genome_fasta}')
                R.append(r)
                break

    with open(out_genome_fasta, "w") as f:
        for r in R:
            f.write(r.format("fasta"))


logger = getLogger()
logger.setLevel(DEBUG)
stream_handler = StreamHandler()
stream_handler.setLevel(DEBUG)
logger.addHandler(stream_handler)
gbk_file_base = "OUT/genome.gbk"
gbk_file_repeat = "REPEAT/genome.gbk"
out_genome_fasta = "merged.genome.fasta"
parser = argparse.ArgumentParser(description='Utility script to merge assembly.',
                                 usage=None, epilog=None,
                                 # formatter_class=argparse.ArgumentDefaultsHelpFormatter,
                                 add_help=True # allow_abbrev=False
                                 # argument_default=argparse.SUPPRESS
                                 )


parser.add_argument("-b", "--base_gbk", help="Base assembly file", metavar="path", required=True)
parser.add_argument("-r", "--repeat_gbk", help="Repeat assembly file", metavar="path", required=True)
parser.add_argument("-o", "--output_fasta", help="Output file name", metavar="path", required=True)



args = parser.parse_args()

if len(sys.argv) == 1:
    parser.print_help()
    exit()
gbk_file_base = args.base_gbk
gbk_file_repeat = args.repeat_gbk
out_genome_fasta = args.output_fasta
main(gbk_file_base, gbk_file_repeat, out_genome_fasta)