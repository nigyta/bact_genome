cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}

inputs:
  fastq1:
    type: File
  fastq2:
    type: File
  threads:
    type: int
    default: 2
  dfast_cpu:
    type: int
    default: 3
  genome_size:
    type: float
    default: 3.0
  coverage:
    type: int
    default: 100

  

steps:
  preprocessing:
    run: preprocessing.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      genome_size: genome_size
      coverage: coverage
    out: [subsampled_fastq1, subsampled_fastq2]

  assemble:
    run: platanusB-w-rRNA.cwl
    in:
      fastq1: preprocessing/subsampled_fastq1
      fastq2: preprocessing/subsampled_fastq2
      threads: threads
    out: [contig, scaffold, kmerfreq, repeat]

  annotation:
    run: annotation.cwl
    in:
      genome: assemble/scaffold
      repeat_contig: assemble/repeat
      num_cpu: dfast_cpu
    out: [merged_genome_result, dfast_result]

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
    - id: repeat
      type: File
      outputSource: assemble/repeat
    - id: merged_genome
      type: File
      outputSource: annotation/merged_genome_result
    - id: dfast_result
      type: Directory
      outputSource: annotation/dfast_result
