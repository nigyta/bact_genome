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
  num_threads:
    type: int
    default: 1
  taxid:
    type: int
    default: 0
  reference:
    type: Directory

steps:
  dfast_qc:
    run: ../tool/dfastqc/dfastqc.cwl
    scatter: input
    in:
      input: genome_list
      reference: reference
      outdir:
         valueFrom: $(inputs.input.nameroot)
      taxid: taxid
      num_threads: num_threads
    out: [result]

outputs:
  result:
    type: Directory[]
    outputSource: dfast_qc/result
