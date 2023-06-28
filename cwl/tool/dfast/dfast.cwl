#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: CommandLineTool
baseCommand: dfast

requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      OMP_NUM_THREADS: "1"
      MALLOC_ARENA_MAX: "1"
  DockerRequirement:
    dockerPull: nigyta/dfast_core:1.2.18
    # dockerPull: quay.io/biocontainers/dfast:1.2.4--py37h8b12597_0
    # dockerImageId:  dfast-cwl:1.2.4
    #dockerFile:
    #  $include: ./Dockerfile

arguments: []
# - --no_cds
#  - id: locus_tag_prefix
#    prefix: --locus_tag_prefix
#    valueFrom: |
#        ${
#          if (inputs.locus_tag_prefix === null) {
#            return inputs.strain === null ? "LOCUS" : inputs.strain;
#          } else {
#            return self;
#          }
#        }
  
inputs: 
  genome:
    type: File
    inputBinding:
      prefix: --genome
  dbroot:
    type: Directory
    inputBinding:
      prefix: --dbroot
  out_dir:
    type: string
    default: "annotation"
    inputBinding:
      prefix: --out
  metadata:
    type: File?
    inputBinding:
      prefix: --metadata_file
  organism:
    type: string?
    inputBinding:
      prefix: --organism
  strain:
    type: string?
    inputBinding:
      prefix: --strain
  locus_tag_prefix:
    type: string?
    inputBinding:
      prefix: --locus_tag_prefix
  no_hmm:
    type: boolean
    default: false
    inputBinding:
      prefix: --no_hmm
  no_cdd:
    type: boolean
    default: false
    inputBinding:
      prefix: --no_cdd
  cpu:
    type: int
    default: 1
    inputBinding:
      prefix: --cpu

#  no_rrna:
#    inputBinding: 
#      valueFrom: |
#        ${ if(self === null) { return null;} else {return "--no_rrna"} }
outputs: 
  result:
    type: Directory
    outputBinding:
      glob: $(inputs.out_dir)
