#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [platanus_b, assemble]

requirements:
  InlineJavascriptRequirement: {}
hints: 
  DockerRequirement:
    dockerImageId:  platanus_b:1.1.0
    dockerFile:
      $include: ./Dockerfile

arguments: [-f, $(inputs.fastq1), $(inputs.fastq2), -repeat]

inputs: 
  fastq1:
    type: File
    label: "FASTQ File1 (forward)"
    doc: "FASTQ File2 (forward)"
  fastq2:
    type: File
    label: "FASTQ File2 (reverse)"
    doc: "FASTQ File2 (reverse)"
  threads:
    type: int
    label: "number of threads"
    doc: "Number of threads"
    default: 1
    inputBinding:
      prefix: -t
  prefix:
    type: string
    label: "prefix of output files"
    doc: "Prefix of output files (default: out)"
    default: out
    inputBinding:
      prefix: -o


outputs: 
  repeat_contig:
    type: File
    outputBinding:
      glob: $(inputs.prefix)_contig.fa
      outputEval: ${self[0].basename=inputs.prefix + '_repeat.fa'; return self;}
