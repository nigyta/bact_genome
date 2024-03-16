cwlVersion: v1.2
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.input_dir)
        entryname: $(inputs.outdir_prefix)/$(inputs.input_dir.location.split('/')[inputs.input_dir.location.split('/').length-1].substring(0,3))/$(inputs.input_dir.location.split('/')[inputs.input_dir.location.split('/').length-1].substring(4,7))/$(inputs.input_dir.location.split('/')[inputs.input_dir.location.split('/').length-1].substring(7,10))/$(inputs.input_dir.location.split('/')[inputs.input_dir.location.split('/').length-1].substring(10,13))/$(inputs.dest_dirname)
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

