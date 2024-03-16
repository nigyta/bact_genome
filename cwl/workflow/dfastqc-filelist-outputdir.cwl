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
    scatter: genome
    in:
      genome: genome_list
      reference: reference
      outdir:
         valueFrom: $(inputs.genome.location.split('/')[inputs.genome.location.split('/').length-2])
      taxid: taxid
      num_threads: num_threads
    out: [result]

outputs:
  result:
    type: Directory[]
    outputSource: dfast_qc/result
