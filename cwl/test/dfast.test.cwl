- job: ../tool/dfast/dfast.job.cwl
  tool: ../tool/dfast/dfast.cwl 
  output:
    result:
      class: Directory
      basename: annotation
    #  checksum: sha1$308a0b5b7885122c00b5c45654e73c889ea8f03c
    #  size: 408
    # subsampled_fastq1:
    #   class: File
    #   basename: test_R1_001.fastp.100x.fastq
    #   checksum: sha1$87fc25c257f7708350e46b159c16a153e0d97166
    #   size: 4737463
  doc: dfast test file
