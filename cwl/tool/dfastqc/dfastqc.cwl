#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.2

requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      OMP_NUM_THREADS: "1"
      MALLOC_ARENA_MAX: "1"
  DockerRequirement:
    dockerPull: nigyta/dfast_qc:0.5.7_2

baseCommand: dfast_qc

arguments:
  - -i
  - $(inputs.input)
  - -o
  - $(inputs.outdir)
  - --num_threads
  - $(inputs.num_threads)
  - --taxid
  - $(inputs.taxid)
  - --enable_gtdb
#  - --disable_tc
inputs:
  - id: input
    type: File
  - id: outdir
    type: string
  - id: num_threads
    type: int
    default: 1
  - id: taxid
    type: int
    default: 0
  - id: reference
    type: Directory
    inputBinding:
      prefix: -r

outputs:
  result:
    type: Directory
    outputBinding:
      glob: $(inputs.outdir)
