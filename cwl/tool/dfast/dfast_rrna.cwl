#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: dfast

requirements: 
  DockerRequirement:
    dockerPull: nigyta/dfast:1.2.4
    # dockerPull: quay.io/biocontainers/dfast:1.2.4--py37h8b12597_0
    # dockerImageId:  dfast-cwl:1.2.4
    #dockerFile:
    #  $include: ./Dockerfile

arguments: [-g, $(inputs.genome), --cpu, $(inputs.cpu), -o, $(inputs.out_dir), --no_cds, --no_trna, --no_crispr]


inputs: 
  genome:
    type: File
  cpu:
    type: int
    default: 1
  out_dir:
    type: string
    default: OUT
outputs: 
  gbk:
    type: File
    outputBinding:
      glob: $(inputs.out_dir)/genome.gbk
