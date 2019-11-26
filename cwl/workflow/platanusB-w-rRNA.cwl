cwlVersion: v1.0
class: Workflow
inputs:
  fastq1:
    type: File
  fastq2:
    type: File
  threads:
    type: int
    default: 1
  prefix:
    type: string
    default: out

steps:
  assemble:
    run: ../tool/platanus_b/platanusB_assemble.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      prefix: prefix
      threads: threads
    out: [contig, kmerfreq]
  iterate:
    run: ../tool/platanus_b/platanusB_iterate.cwl
    in:
      contig: assemble/contig
      fastq1: fastq1
      fastq2: fastq2
      prefix: prefix
      threads: threads
    out: [scaffold]

  repeat_assemble:
    run: ../tool/platanus_b/platanusB_repeat.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      prefix: prefix
      threads: threads
    out: [repeat_contig]

outputs:
    - id: contig
      type: File
      outputSource: assemble/contig
    - id: kmerfreq
      type: File
      outputSource: assemble/kmerfreq
    - id: scaffold
      type: File
      outputSource: iterate/scaffold
    - id: repeat
      type: File
      outputSource: repeat_assemble/repeat_contig
