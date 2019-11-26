#!/usr/bin/env python
# coding:utf-8

import math
import sys

class Fasta():

    @staticmethod
    def read(inputfile):
        a = open(inputfile).read()
        entries = a.split(">")[1:]
        for entry in entries:
            lines = entry.split("\n")
            fasta = Fasta()
            fasta.header = ">" + lines[0]
            fasta.seq = "".join(lines[1:])
            fasta.length = len(fasta.seq)
            yield fasta

def main(fileName, threshold=0):
    seqList = [seq for seq in Fasta.read(fileName) if seq.length >= threshold]
    seqList.sort(key=lambda seq: seq.length, reverse=True)
    digit = int(math.log10(len(seqList))) + 1
    for i, seq in enumerate(seqList):
        print(">sequence" + str(i + 1).zfill(digit))
        print(seq.seq)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print()
        print("\tRemove sequences shorter than <threshold>.")
        print("\tSequences will be renamed as 'sequence00X' and sorted by length.")
        print()
        print("\tUsage : fastaLengthFilter.py <filename> <threshold:int>")
        print()
        exit()

    fileName, threshold = sys.argv[1:3]
    main(fileName, int(threshold))
