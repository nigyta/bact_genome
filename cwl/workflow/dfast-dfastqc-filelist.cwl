#!/usr/bin/env cwl-runner

cwlVersion: v1.2
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
  use_original_name:
    type: boolean
    default: true
  sort_sequence:
    type: boolean
    default: true
  ## for dfast result move
  dfast_outdir_prefix:
    type: string
    default: all
  dfast_dest_dirname:
    type: string
    default: dfast

  # for dfastqc
  num_threads:
    type: int
    default: 1
  taxid:
    type: int
    default: 0
  reference:
    type: Directory
  ## for dfast result move
  dfastqc_outdir_prefix:
    type: string
    default: all
  dfastqc_dest_dirname:
    type: string
    default: dfastqc
steps:
  dfast:
    run: ./dfast-filelist.cwl
    in:
      genome_list: genome_list
      dbroot: dbroot
      metadata: metadata
      organism: organism
      strain: strain
      locus_tag_prefix: locus_tag_prefix
      no_hmm: no_hmm
      no_cdd: no_cdd
      cpu: cpu
      use_original_name: use_original_name
      sort_sequence: sort_sequence
    out: [result]
  dfast_moveoutput:
    run: ../tool/moveoutput.cwl
    scatter: input_dir
    in:
      outdir_prefix: dfast_outdir_prefix
      dest_dirname: dfast_dest_dirname
      input_dir: dfast/result
    out:
      - output_dir
  #
  dfastqc:
    run: ./dfastqc-filelist.cwl
    in:
      genome_list: genome_list
      num_threads: num_threads
      taxid: taxid
      reference: reference
    out: [result]
  dfastqc_moveoutput:
    run: ../tool/moveoutput.cwl
    scatter: input_dir
    in:
      outdir_prefix: dfastqc_outdir_prefix
      dest_dirname: dfastqc_dest_dirname
      input_dir: dfastqc/result
    out:
      - output_dir
      

outputs: 
  dfast_result:
    type: Directory[]
    outputSource: dfast_moveoutput/output_dir
  dfastqc_result:
    type: Directory[]
    outputSource: dfastqc_moveoutput/output_dir
