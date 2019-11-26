#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements:
    DockerRequirement:
        dockerPull: quay.io/biocontainers/seqkit:0.11.0--0

baseCommand: [seqkit, stats]
arguments:
    - -a
    - -G N
    - $(inputs.fasta)
    
inputs:
    fasta: File[]
    stats_out:
      type: string?
      default: fasta-stats.txt
  

outputs:
  result:
    type: stdout  
stdout: $(inputs.stats_out)