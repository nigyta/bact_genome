cwlVersion: v1.0
class: Workflow
requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
inputs:
  genome:
    type: File
  repeat_contig:
    type: File
  num_cpu:
    type: int
    default: 2
  merged_genome:
    type: string
    default: merged.genome.fasta
steps:
  rna_annotation_base:
    run: ../tool/dfast_rrna.cwl
    in:
      genome: genome
    out: [gbk]
  rna_annotation_repeat:
    run: ../tool/dfast_rrna.cwl
    in:
      genome: repeat_contig
    out: [gbk]
  merge_assembly:
    run: ../tool/merge_assembly.cwl
    in:
      base_gbk: rna_annotation_base/gbk
      repeat_gbk: rna_annotation_repeat/gbk
      output_fasta: merged_genome
    out: [merged_genome]
  annotation:
    run: ../tool/dfast.cwl
    in:
      cpu: num_cpu
      genome: merge_assembly/merged_genome
      out_dir:
        valueFrom: "output_dfast"
      no_hmm:
        valueFrom: $(true)
    out: [result]
outputs:
    merged_genome_result:
      type: File
      outputSource: merge_assembly/merged_genome
    dfast_result:
      type: Directory
      outputSource: annotation/result
