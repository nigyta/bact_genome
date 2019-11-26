cwlVersion: v1.0  # or v1.1

# https://www.commonwl.org/user_guide/misc/

class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ echo ]
arguments: [$(inputs.proportion)]
inputs:
  proportion: float

stdout: proportion.txt

outputs:
  proportion:
    type: float
    outputBinding:
       glob: proportion.txt
       loadContents: True
       outputEval: $(parseFloat(self[0].contents))
