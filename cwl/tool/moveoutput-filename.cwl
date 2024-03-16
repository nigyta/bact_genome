cwlVersion: v1.2
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.input_dir)
        entryname: $(inputs.outdir_prefix)/$(inputs.input_dir.basename.split('.')[0])/$(inputs.dest_dirname)
        writable: true
      #
baseCommand: ["true"]

inputs:
  - id: outdir_prefix
    type: string
  - id: dest_dirname
    type: string
  - id: input_dir
    type: Directory


outputs:
  - id: output_dir
    type: Directory
    outputBinding:
      glob: $(inputs.outdir_prefix)

