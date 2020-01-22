#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements:
  # InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: nigyta/dfast:1.2.4
    # dockerPull: quay.io/biocontainers/dfast:1.2.4--py37h8b12597_0
    # dockerImageId:  dfast-cwl:1.2.4
    # dockerFile:
    #   $include: ../dfast/Dockerfile


baseCommand: [python]
arguments: [$(inputs.script), --base_gbk, $(inputs.base_gbk), --repeat_gbk, $(inputs.repeat_gbk), --output_fasta, $(inputs.output_fasta)]
inputs:
    # outdir: string
    script:
      type: File
      default:
        class: File
        location: merge_rrna_contigs.py
    base_gbk: File
    repeat_gbk: File
    output_fasta:
        type: string
        default: merged.genome.fasta

outputs:
  merged_genome:
    type: File
    outputBinding:
       glob: $(inputs.output_fasta)
