#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: nigyta/dfast:1.2.4
    # dockerPull: quay.io/biocontainers/dfast:1.2.4--py37h8b12597_0
    # dockerImageId:  dfast-cwl:1.2.4
    # dockerFile:
    #   $include: ../dfast/Dockerfile



baseCommand: [python]
arguments:
  # python calc_depth.py coverage --stats_file read-stats.txt --genome_size 2.5 --coverage 100
  - $(inputs.script)
  - proportion

inputs:
    script:
      type: File
      default:
        class: File
        location: calc_depth.py
    stats_file:
      type: File
      inputBinding:
        prefix: --stats_file
    genome_size:
      type: float
      default: 3.0
      inputBinding:
        prefix: --genome_size
    coverage:
      type: int
      default: 100
      inputBinding:
        prefix: --coverage

stdout: proportion.txt

outputs:
  proportion:
    type: float
    outputBinding:
       glob: proportion.txt
       loadContents: True
       outputEval: $(parseFloat(self[0].contents.split('\t')[0]))

  coverage_out:
    type: int
    outputBinding:
      glob: proportion.txt
      loadContents: True
      outputEval: $(parseInt(self[0].contents.split('\t')[1]))

  proportion_file:
    type: File
    outputBinding:
       glob: proportion.txt
