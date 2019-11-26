#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  fastq1:
    type: File
  fastq2:
    type: File
  threads:
    type: int
    default: 1
  genome_size:
    type: float
    default: 3.0
  coverage:
    type: int
    default: 100

steps:
  fastqc_raw:
    run: ../tool/fastqc/fastqc-PE.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      threads: threads
    out: [result1, result2]

  seqkit_stats_raw:
    run: ../tool/seqkit/seqkit-stats-PE.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      threads: threads
      stats_out:
        valueFrom: read-stats_raw.txt
    out: [result]

  fastp:
    run: ../tool/fastp/fastp.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      threads: threads
    out: [out_fastq1, out_fastq2]

  seqkit_stats_fastp:
    run: ../tool/seqkit/seqkit-stats-PE.cwl
    in:
      fastq1: fastp/out_fastq1
      fastq2: fastp/out_fastq2
      threads: threads
      stats_out:
        valueFrom: read-stats_fastp.txt
    out: [result]

  calc_proportion:
    run: ../tool/dfast-utility/util_calc_proportion.cwl
    in:
      coverage: coverage
      genome_size: genome_size
      stats_file: seqkit_stats_raw/result
    out: [proportion, coverage_out, proportion_file]

  seqkit_subsample1:
    run: ../tool/seqkit/seqkit-sample.cwl
    in:
      fastq: fastp/out_fastq1
      proportion: calc_proportion/proportion
      coverage: calc_proportion/coverage_out
    out: [output]

  seqkit_subsample2:
    run: ../tool/seqkit/seqkit-sample.cwl
    in:
      fastq: fastp/out_fastq2
      proportion: calc_proportion/proportion
      coverage: calc_proportion/coverage_out
    out: [output]

  seqkit_stats_subsample:
    run: ../tool/seqkit/seqkit-stats-PE.cwl
    in:
      fastq1: seqkit_subsample1/output
      fastq2: seqkit_subsample2/output
      threads: threads
      stats_out:
        valueFrom: read-stats_subsample.txt
    out: [result]

  fastqc_subsampled:
    run: ../tool/fastqc/fastqc-PE.cwl
    in:
      fastq1: seqkit_subsample1/output
      fastq2: seqkit_subsample2/output
      threads: threads
    out: [result1, result2]

outputs:
    fastqc_result_raw1:
      type: File
      outputSource: fastqc_raw/result1
    fastqc_result_raw2:
      type: File
      outputSource: fastqc_raw/result2
    fastqc_result_subsampled1:
      type: File
      outputSource: fastqc_subsampled/result1
    fastqc_result_subsampled2:
      type: File
      outputSource: fastqc_subsampled/result2

    fastp_fastq1:
      type: File
      outputSource: fastp/out_fastq1
    fastp_fastq2:
      type: File
      outputSource: fastp/out_fastq2


    subsampled_fastq1:
      type: File
      outputSource: seqkit_subsample1/output
    subsampled_fastq2:
      type: File
      outputSource: seqkit_subsample2/output

    read-stats_raw:
      type: File
      outputSource: seqkit_stats_raw/result
    read-stats_fastp:
      type: File
      outputSource: seqkit_stats_fastp/result
    read-stats_subsample:
      type: File
      outputSource: seqkit_stats_subsample/result
