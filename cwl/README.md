# バクテリアゲノム解析 (denovo アセンブリ ~ アノテーション) のワークフロー
ペアエンドのFASTQファイルを入力として、リードの前処理、de novo アセンブリ、アノテーションまでを一括して行うワークフロー。
__開発中のため、一部のオプションの指定や、中間ファイルの出力が対応できていません。__
## 使用方法
### 動作環境
Docker (or Singularity)、cwltool、node.js が必要。  
- Docker のインストール  
  Mac 用の Docker は、[公式サイト](https://hub.docker.com/editions/community/docker-ce-desktop-mac)からインストーラーがダウンロードできる。  
  ダウンロードするためには Docker のアカウントを作成しておく必要がある。Dockerアカウントは起動時にも必要。  
  インストールには管理者権限が必要。  
  Preferences -> Advanced で CPU、メモリの割当を行う。動作確認は 2 CPU、メモリ4Gbyte で実行。
- cwltool のインストール (python3が必要)  
  ```
  pip install cwltool
  ```
  または、conda を使う場合
  ```
  conda install cwltool
  ```
- node.js のインストール  
  一部の cwl は javascript を利用しているため必要となります。ホームディレクトリにインストールする場合、ndenv や conda を使うと簡単。conda 利用する場合、下記コマンドでインストール可能。
  ```
  conda install nodejs
  ```

### 簡単な使い方
  ```
  # ヘルプの表示
  cd cwl
  cwltool workflow/assemble_and_annotation.cwl -h
  
  # テストデータでの実行
  cd test
  cwltool --outdir test_result ../workflow/assemble_and_annotation.cwl --coverage 120 --genome_size 0.04 --fastq1 test_R1_001.fastq.gz --fastq2 test_R2_001.fastq.gz --threads 2 --dfast_cpu 2
  ```
   テストデータは40kbpのプラスミド配列のデータなので、推定ゲノムサイズとして --genome_size には 0.04 (Mbp) を指定。カバレッジが120xになるようデータのサブサンプリングを行いアセンブリを行う。  
   結果ファイルは `test_result` に出力される。

### 遺伝研スパコンでの実行方法
遺伝研スパコンでは Docker が使えないが、`--singularity`オプションを指定することで Singularity で代用することができる。  
__現状、Singularity コンテナのビルドが一部失敗するため、下記は動作しない（近日対応予定）__
  ```
  cwltool --singularity --outdir test_result ../workflow/assemble_and_annotation.cwl --coverage 120 --genome_size 0.04 --fastq1 test_R1_001.fastq.gz --fastq2 test_R2_001.fastq.gz --threads 2 --dfast_cpu 2
  ```
  既知のトラブル
  - 'Out of memory' で singularity イメージのビルドに失敗する。  
    [解決方法] qlogin 時や、qsub でバッチジョブを投入する際に、`-l mem_req=16G,s_vmem=16G` オプションを指定して、メモリを多く要求する。
  - Dockerfile からの singularity イメージのビルドに失敗する  
    現状では、cwltool が対応していないため回避策無し。  
    ビルド済みの Docker イメージを公開することで対応予定。
  - DFAST の Barrnap のステップで失敗する。  
    DFAST 側で対応予定。 
## ワークフローについて
### リードの前処理
- 入力データは、PEのFASTQ  
- 拡張子は .fq or .fastq  
- gz or bzip2 で圧縮されていても可 (i.e. read.fq.gz, read.fastq.bz2)
- 使用コンテナ  
    - biocontainers/fastqc:v0.11.5_cv4  
    - quay.io/biocontainers/seqkit:0.11.0--0  
    - quay.io/biocontainers/fastp:0.20.0--hdbcaa40_0  

1. クオリティチェック FastQC  
2. リード統計量算出 seqkit stats  
3. トリミング・アダプター配列除去 fastp  
4. 必要なカバレッジとゲノムサイズを指定して、抽出するリードの割合を計算  
  in-house script (calc_depth.py)
1. 上記割合を指定して seqkit sample でリード抽出 (read1, read2 それぞれ実行)
1. 抽出した FASTQ に対して seqkit stats 実行
1. 抽出した FASTQ に対して FastQC 実行  

### アセンブリ
- 使用コンテナ  
    - platanus_b (Dockerfileからイメージ作成)  
1. platanus_b assemble 実行
1. platanus_b iterate 実行 
1. アセンブル結果 (FASTAファイル) の統計値算出 seqkit stats
### アノテーション
- 使用コンテナ  
    - nigyta/dfast:1.2.4
1. DFAST 実行
1. 統計値算出
