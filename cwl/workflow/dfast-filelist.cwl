#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

  
inputs: 
  genome_list:
    type: File[]
  dbroot:
    type: Directory
  metadata:
    type: File?
  organism:
    type: string?
  strain:
    type: string?
  locus_tag_prefix:
    type: string?
  no_hmm:
    type: boolean
    default: false
  no_cdd:
    type: boolean
    default: false
  cpu:
    type: int
    default: 1

steps:
  dfast:
    run: ../tool/dfast/dfast.cwl
    scatter: genome
    in:
      genome: genome_list
      dbroot: dbroot
      out_dir:
         valueFrom: $(inputs.genome.nameroot)
      metadata: metadata
      organism: organism
      strain: strain
      locus_tag_prefix: locus_tag_prefix
      no_hmm: no_hmm
      no_cdd: no_cdd
      cpu: cpu
    out: [result]

outputs: 
  result:
    type: Directory[]
    outputSource: dfast/result