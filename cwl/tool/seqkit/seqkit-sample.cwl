#!/usr/bin/env cwl-runner


cwlVersion: v1.0
class: CommandLineTool
requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/seqkit:0.11.0--0


baseCommand: [seqkit, sample]
arguments: [-p, $(inputs.proportion), $(inputs.fastq)]
inputs:
    fastq: File
    proportion: float
    # result: string
    coverage: int

outputs:
  output:
    type: stdout  

# stdout: $(inputs.result)
stdout: $(inputs.fastq.nameroot).$(String(inputs.coverage))x$(inputs.fastq.nameext)