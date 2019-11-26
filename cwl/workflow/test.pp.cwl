#!/usr/bin/env cwl-runner

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
cwlVersion: v1.0
class: Workflow

inputs:
  fastq1:
    type: File
  fastq2:
    type: File
  threads:
    type: int
  test_out_read1:
    type: string
    default: XXXXX.read1.fastq
steps:
##  fastqc_raw:
##    run: ../tool/fastqc/fastqc-PE.cwl
#   in:
#      fastq1: fastq1
#      fastq2: fastq2
#      threads: threads
#    out: [result1, result2]

  seqkit_subsample1:
    run: ../tool/seqkit/seqkit-sample.cwl
    in:
      fastq: fastq1
      proportion:
        valueFrom: $(parseFloat('0.65'))
      result:
      #  valueFrom: "read1.100x.test.test.fastq"
        valueFrom: $(inputs.fastq.nameroot + '.test.test.fastq')
      # test_out_read1
      # valueFrom: "read1.100x.fastq"
      # coverage: calc_proportion/coverage_out
    out: [output]

  seqkit_subsample2:
    run: ../tool/seqkit/seqkit-sample.cwl
    in:
      fastq: fastq2
      proportion:
        valueFrom: $(0.65)
      result:
      #  valueFrom: "read1.100x.test.test.fastq"
        valueFrom: $(inputs.fastq.nameroot + '.testXX.testXX.fastq' + self.seqkit_subsample1.proportion)
      # test_out_read1
      # valueFrom: "read1.100x.fastq"
      # coverage: calc_proportion/coverage_out
    out: [output]
outputs:
#    fastqc_result_raw1:
#     type: File
#     outputSource: fastqc_raw/result1
#   fastqc_result_raw2:
#     type: File
#     outputSource: fastqc_raw/result2
    subsampled_fastq1:
      type: File
      outputSource: seqkit_subsample1/output      
    subsampled_fastq2:
      type: File
      outputSource: seqkit_subsample2/output           