#!/bin/env python

import sys
import argparse

def calculate_coverage(stats_file, genome_size):
    genome_size = genome_size * 10**6
    lines = open(stats_file).readlines()
    line1 = lines[1].strip()
    line2 = lines[2].strip()
    length1 = int(line1.split()[4].replace(",", ""))
    length2 = int(line2.split()[4].replace(",", ""))
    # print(length1, length2)
    estimated_coverage = (length1 + length2) / genome_size
    return estimated_coverage    


def get_proportion(args):
    stats_file = args.stats_file
    genome_size = args.genome_size
    coverage = args.coverage

    estimated_coverage = calculate_coverage(stats_file, genome_size)
    if coverage < 0:
        # negative value means "no subsampling"
        sys.stdout.write("1")
        sys.stdout.write("\t")
        sys.stdout.write(str(int(estimated_coverage)))
        return

    proportion = coverage / estimated_coverage
    if proportion > 1:
        sys.stdout.write("1")
        sys.stdout.write("\t")
        sys.stdout.write(str(int(estimated_coverage)))
        return
    proportion = f"{proportion:.3f}"
    sys.stdout.write(proportion)
    sys.stdout.write("\t")
    sys.stdout.write(str(int(coverage)))

def get_coverage(args):
    stats_file = args.stats_file
    genome_size = args.genome_size
    coverage = calculate_coverage(stats_file, genome_size)
    coverage = f"{coverage:.0f}"
    sys.stdout.write(coverage)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Utility script to calculate genome coverage.',
                                     usage=None, epilog=None,
                                     # formatter_class=argparse.ArgumentDefaultsHelpFormatter,
                                     add_help=True # allow_abbrev=False
                                     # argument_default=argparse.SUPPRESS
                                     )
    subparsers = parser.add_subparsers(help='')


    parser_coverage = subparsers.add_parser('coverage', help='Calculate genome coverage from seqkit-stats.')
    parser_coverage.add_argument("-s", "--stats_file", help="seqkit stats file", metavar="path", required=True)
    parser_coverage.add_argument("-g", "--genome_size", help="Estimated genome size in Mbase (3.0Mb)", metavar="float", type=float, default=3.0)
    parser_coverage.set_defaults(func=get_coverage)


    parser_proportion = subparsers.add_parser('proportion', help='Calculate proportion for subsampling FASTQ.')
    parser_proportion.add_argument("-s", "--stats_file", help="seqkit stats file", metavar="path", required=True)
    parser_proportion.add_argument("-g", "--genome_size", help="Estimated genome size in Mbase (3.0Mb)", metavar="float", type=float, default=3.0)
    parser_proportion.add_argument("-c", "--coverage", help="Depth coveraeg for subsampling (100x)", metavar="int", type=float, default=100)
    parser_proportion.set_defaults(func=get_proportion)

    args = parser.parse_args()

    if len(sys.argv) == 1:
        parser.print_help()
        exit()
    args.func(args)

