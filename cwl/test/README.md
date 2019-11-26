# テスト用データについて

## 概要
- 長さ40kbのプラスミドゲノム AP014682
- [sandy](https://galantelab.github.io/sandy/) で生成した 100bp-PE のダミーリード
- カバレッジ x150

## テストデータ作成方法
```
$ docker pull galantelab/sandy
$ docker run --rm -v  $PWD:/data/ galantelab/sandy genome --verbose --sequencing-type=paired-end --coverage=150 --prefix test /data/test.genome.fna -o /data/.
```
test_R1_001.fastq.gz および test_R2_001.fastq.gz  が生成される。  

```
$ seqkit stats *gz
file                  format  type  num_seqs    sum_len  min_len  avg_len  max_len
test_R1_001.fastq.gz  FASTQ   DNA     30,728  3,072,800      100      100      100
test_R2_001.fastq.gz  FASTQ   DNA     30,728  3,072,800      100      100      100
```

## 個別実行テスト
```
mkdir OUT 
cd OUT

# 前処理 ------------

# FastQC (raw data)
cwltool ../../tool/fastqc/fastqc-PE.cwl --fastq1 ../test_R1_001.fastq.gz --fastq2 ../test_R2_001.fastq.gz --threads 2
# output --> test_R1_001_fastqc.html test_R2_001_fastqc.html


# seqkit stats
cwltool ../../tool/seqkit/seqkit-stats-PE.cwl --fastq1 ../test_R1_001.fastq.gz --fastq2 ../test_R2_001.fastq.gz --threads 2 --stats_out read-stats_raw.txt
# output --> read-stats_raw.txt


# fastp
cwltool ../../tool/fastp/fastp.cwl --fastq1 ../test_R1_001.fastq.gz --fastq2 ../test_R2_001.fastq.gz --threads 2
# output --> test_R1_001.fastp.fastq test_R2_001.fastp.fastq


# seqkit stats (for fastp-processed files)
cwltool ../../tool/seqkit/seqkit-stats-PE.cwl --fastq1 test_R1_001.fastp.fastq --fastq2 test_R1_001.fastp.fastq --threads 2 --stats_out read-stats_fastp.txt
# output --> read-stats_fastp.txt


# seqkit で subsampling するために必要な割合をゲノムサイズとリード数から計算
# ゲノムサイズ 40kb なので genome_size には 0.04 (Mb) を指定
cwltool ../../tool/dfast-utility/util_calc_proportion.cwl --stats_file read-stats_fastp.txt --genome_size 0.04 --coverage 100
# output --> proportion.txt と、proportion値 (0.651), coverage_out値 (100)


# seqkit subsample
cwltool ../../tool/seqkit/seqkit-sample.cwl --fastq test_R1_001.fastp.fastq --proportion 0.651 --coverage 100
cwltool ../../tool/seqkit/seqkit-sample.cwl --fastq test_R2_001.fastp.fastq --proportion 0.651 --coverage 100
# output --> test_R1_001.fastp.100x.fastq test_R2_001.fastp.100x.fastq


# seqkit stats (subsampling したリード)
cwltool ../../tool/seqkit/seqkit-stats-PE.cwl --fastq1 test_R1_001.fastp.100x.fastq --fastq2 test_R2_001.fastp.100x.fastq --threads 2 --stats_out read-stats_subsample.txt
# output --> read-stats_subsample.txt


# FastQC (subsampling したリード)
cwltool ../../tool/fastqc/fastqc-PE.cwl --fastq1 test_R1_001.fastp.100x.fastq --fastq2 test_R2_001.fastp.100x.fastq --threads 2
# output --> test_R1_001.fastp.100x_fastqc.html test_R2_001.fastp.100x_fastqc.html

```



## ワークフロー実行テスト
```
cwltool ../../workflow/preprocessing.cwl --fastq1 ../test_R1_001.fastq.gz --fastq2 ../test_R2_001.fastq.gz --thread 3 --genome_size 0.04 --coverage 80

# または



cwltool ../../workflow/preprocessing.cwl ../../workflow/preprocessing.test.yaml

```

## アセンブリ
```
cwltool ../../tool/platanus_b/platanusB_assemble.cwl --fastq1 test_R1_001.fastp.100x.fastq --fastq2 test_R2_001.fastp.100x.fastq --prefix PLOOC --threads 4
# output --> PLOOC_32merFrq.tsv PLOOC_contig.fa


cwltool ../../tool/platanus_b/platanusB_iterate.cwl --contig PLOOC_contig.fa --fastq1 test_R1_001.fastp.100x.fastq --fastq2 test_R2_001.fastp.100x.fastq --prefix PLOOC --threads 4

# repetitive 領域 (rRNA 領域) のアセンブル -repeat オプション使用
# テスト用データでは正常に動作しない!
$ cwltool ../../tool/platanus_b/platanusB_repeat.cwl --fastq1 test_R1_001.fastp.100x.fastq --fastq2 test_R2_001.fastp.100x.fastq --prefix PLOOC --threads 4

# JCMのデータで実行した
cwltool ../../workflow/platanusB-w-rRNA.cwl --fastq1 ../../../../JCM1025.50x.R1.fastq --fastq2 ../../../../JCM1025.50x.R2.fastq --prefix JCM --thread 4

# stats
cwltool ../../tool/seqkit/seqkit-stats-FASTA.cwl --fasta PLOOC_contig.fa --fasta PLOOC_iterativeAssembly.fa

```
## ワークフロー実行
```
cwltool ../../workflow/platanusB-default.cwl --fastq1 test_R1_001.fastp.100x.fastq --fastq2 test_R2_001.fastp.100x.fastq --prefix PLOOC --threads 4
```

## アノテーション
```
cwltool ../../tool/dfast/dfast.cwl --genome PLOOC_iterativeAssembly.fa 
``` 



## アセンブル&アノテーション 全ワークフロー実行 (fastq to annotation)
```
cwltool ../../workflow/assemble_and_annotation.cwl --coverage 120 --genome_size 0.04 --fastq1 ../test_R1_001.fastq.gz --fastq2 ../test_R2_001.fastq.gz --threads 3 --dfast_cpu 2
```


