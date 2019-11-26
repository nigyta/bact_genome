cwlVersion: v1.0  # or v1.1
class: Workflow
inputs:
  fastq:
    type: File
  genome_size:
    type: float
    default: 3.0
  coverage:
    type: int
    default: 100
  stats_file:
    type: File

    # - id: fastq
    #   type: File
    # - id: genome_size
    #   type: float
    # - id: stats_file
    #   type: File
    # - id: coverage
    # type: float
steps:
  calc_proportion:
    run: ../tool/util_calc_proportion.cwl
    in:
      coverage: coverage
      genome_size: genome_size
      stats_file: stats_file
    out: [proportion, proportion_file]
  seqkit_sample:
    run: ../tool/seqkit.sample.cwl
    in:
      fastq: fastq
      proportion: calc_proportion/proportion
    out: [output]

outputs:
    - id: outfastq
      type: File
      outputSource: seqkit_sample/output