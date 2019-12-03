# バクテリアゲノム解析 (denovo アセンブリ ~ アノテーション) のワークフロー

## リードの前処理
- 入力データは、PEのFASTQ  
- 拡張子は .fq or .fastqc  
- gz or bzip2 で圧縮されていても可 (i.e. read.fq.gz, read.fastq.bzip2, etc.)
- 使用コンテナ  
    - biocontainers/fastqc:v0.11.5_cv4  
    - quay.io/biocontainers/seqkit:0.11.0--0  
    - quay.io/biocontainers/fastp:0.20.0--hdbcaa40_0  

1. クオリティチェック FastQC  
2. リード統計量算出 seqkit stats  
1. トリミング・アダプター配列除去 fastp  
1. 必要なカバレッジとゲノムサイズを指定して、抽出するリードの割合を計算  
  in-house script (calc_depth.py)
1. 上記割合を指定して seqkit sample でリード抽出 (read1, read2 それぞれ実行)
1. 抽出した FASTQ に対して seqkit stats 実行
1. 抽出した FASTQ に対して FastQC 実行  

## アセンブル
- 使用コンテナ  
    - platanus_b (Dockerfileからイメージ作成)  
1. platanus_b assemble 実行
1. platanus_b iterate 実行 
1. アセンブル結果 (FASTAファイル) の統計値算出 seqkit stats
## アノテーション
- 使用コンテナ  
    - nigyta/dfast:1.2.4
1. DFAST 実行
1. 統計値算出
