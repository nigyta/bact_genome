#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: echo
arguments: [`cat $(inputs.pfile)`]
inputs:
  file_name:
    type: string
    inputBinding:
      position: 1
outputs: []
