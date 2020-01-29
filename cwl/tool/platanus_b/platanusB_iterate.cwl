#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [platanus_b, iterate]

# requirements:
hints: 
  DockerRequirement:
    dockerPull: nigyta/platanus_b:1.1.0
    # dockerImageId:  platanus_b:1.1.0
    # dockerFile:
      # $include: ./Dockerfile

arguments: [-c, $(inputs.contig), -IP1, $(inputs.fastq1), $(inputs.fastq2)]

inputs: 
  contig:
    type: File
  fastq1:
    type: File
  fastq2:
    type: File
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
  scaffold:
    type: File
    outputBinding:
      glob: $(inputs.prefix)_iterativeAssembly.fa
