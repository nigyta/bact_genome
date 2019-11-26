cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}

inputs:
  fastq1:
    type: File
  fastq2:
    type: File
  genome_size:
    type: float
    default: 3.0
  coverage:
    type: int
    default: 100
  prefix:
    type: string
    default: out
    doc: "Prefix for assembled genome file"
  threads:
    type: int
    default: 1
  dfast_cpu:
    type: int
    default: 1

  

steps:
  preprocessing:
    run: preprocessing.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      genome_size: genome_size
      coverage: coverage
      threads: threads
    out: [subsampled_fastq1, subsampled_fastq2]

  assemble:
    run: platanusB-default.cwl
    in:
      fastq1: preprocessing/subsampled_fastq1
      fastq2: preprocessing/subsampled_fastq2
      threads: threads
    out: [contig, scaffold, kmerfreq, stats]

  annotation:
    run: ../tool/dfast/dfast.cwl
    in:
      genome: assemble/scaffold
      # repeat_contig: assemble/contig
      cpu: dfast_cpu
    out: [result]

outputs:
    - id: subsampled_fastq1
      type: File
      outputSource: preprocessing/subsampled_fastq1
    - id: subsampled_fastq2
      type: File
      outputSource: preprocessing/subsampled_fastq2
    - id: scaffold
      type: File
      outputSource: assemble/scaffold
    - id: stats
      type: File
      outputSource: assemble/stats
    - id: dfast_result
      type: Directory
      outputSource: annotation/result
