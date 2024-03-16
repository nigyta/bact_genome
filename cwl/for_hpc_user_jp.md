----
- [Node インストール](#node-インストール)
  - [.bashrcなどにPATHの設定](#bashrcなどにpathの設定)
  - [Toilのインストールと、CWLでのdfastおよびdfastqcの実行](#toilのインストールとcwlでのdfastおよびdfastqcの実行)
    - [Toilとcwltoolバージョンの確認](#toilとcwltoolバージョンの確認)
    - [どのバージョンが良いですか？](#どのバージョンが良いですか)
    - [Multiplexaを使う](#multiplexaを使う)
  - [dfastとdfastqcのCWLを取得](#dfastとdfastqcのcwlを取得)
    - [dfastとdfastqcのバージョン](#dfastとdfastqcのバージョン)
  - [TODO リポジトリ](#todo-リポジトリ)
  - [ジョブファイル構造](#ジョブファイル構造)
    - [dfast](#dfast)
    - [dfastqc](#dfastqc)
    - [qacct用](#qacct用)
    - [Singularityキャッシュの作成](#singularityキャッシュの作成)
      - [qlogin に関する注意点](#qlogin-に関する注意点)
      - [Singulairtyキャッシュ作成用スクリプト取得](#singulairtyキャッシュ作成用スクリプト取得)
      - [Singularityキャッシュ作成スクリプトの実行](#singularityキャッシュ作成スクリプトの実行)
  - [実行方法](#実行方法)
    - [cwltool](#cwltool)
    - [toil](#toil)
  - [スクリプト](#スクリプト)
    - [注意事項](#注意事項)
    - [その他](#その他)


## このドキュメント

このドキュメントは、NIG一般解析区画でのdfast, dfastqc をCWLで実行するためのものです。

しかし、ほとんどのスーパーコンピュータセンターで実行することができます。

- 最初にゲートウェイにログインし、次に計算ノードにqloginします。

### qlogin

ゲートウェイマシンに接続した後、
マシンにqloginします。

# Node インストール

expression などで必要なので以下を追加し、PATHも通しておく

```
mkdir nodejs
cd nodejs
wget https://nodejs.org/dist/v14.17.6/node-v14.17.6-linux-x64.tar.xz
tar Jxvf node-v14.17.6-linux-x64.tar.xz
```

うまく解凍できないときいは、 `xz` コマンドで明示的に解凍したあと
tarを展開してください。

```console
xz -d node-v14.17.6-linux-x64.tar.xz
tar xvf node-v14.17.6-linux-x64.tar
```

## .bashrcなどにPATHの設定

.bashrcなどに

```
export PATH=~/nodejs/node-v14.17.6-linux-x64/bin/:$PATH
```

20230511石井追記
PATHの設定をしたら、いったんログアウトする。
screenやtmuxつかっていたらそこから全部抜けて、ログアウトして再度ログインする。



## Toilのインストールと、CWLでのdfastおよびdfastqcの実行

```bash
python3 -m venv venv
source venv/bin/activate
```

toilをインストールします。

```bash
pip install toil[cwl]==5.11.0
```

### Toilとcwltoolバージョンの確認

このドキュメントを書いたときのバージョンは以下になります。

```bash
- `toil-cwl-runner --version`
- `cwltool --version`
```

|ツール|バージョン|
|---|---|
|toil-cwl-runner|5.11.0|
|cwltool|3.1.20230425144158|

### どのバージョンが良いですか？

お使いの環境におけるPythonの最新バージョンが良いです。
toilも最新安定バージョンが良いです。

[python](https://www.python.org/downloads/)
[toil release history](https://pypi.org/project/toil/#history)

### Multiplexaを使う

以下のようななmultiplexaを使うことをおすすめします。

- screen
- tmux
- byobu

ほとんどの場合、ジョブの実行には時間がかかります。
これらのソフトウェアを使用しない場合、ネットワークが切断され、実行が停止します。

## dfastとdfastqcのCWLを取得

以下のレポジトリを `git clone` します。

```console
git clone https://github.com/nigyta/bact_genome.git
```

### dfastとdfastqcのバージョン

|ツール|バージョン|
|---|---|
|dfast|1.20.0|
|dfastqc|0.5.7_2|

## TODO リポジトリ

dfastおよびdfastqc。

## ジョブファイル構造

### dfast

dbrootを正しく設定します。

```yaml
dbroot:
    class: Directory
    path: /usr/local/resources/mirror/ddbj.nig.ac.jp/dfast/dfast_core_db
cpu: 1
no_hmm: true
no_cdd: true

genome_list:
    - class: File
      path: fna or fna.gz
    ### ここにファイルを列挙していきます。
```

### dfastqc

referenceを正しく設定します。

```yaml
num_threads: 1
reference:
    class: Directory
    path: /usr/local/resources/mirror/ddbj.nig.ac.jp/dfast/dqc_reference

genome_list:
    - class: File
      path: fna or fna.gz
    ### ここにファイルを列挙していきます。
```

### qacct用

qacct用

accoutingというファイルは大きいです。
ジョブのステータスを確認するには、ジョブごとに約10秒かかります。

```shell
${SGE_ROOT}/${SGE_CELL}/common/accounting
```

qacctを高速に実行するするためのスクリプトについては後述します。

### Singularityキャッシュの作成

Singularityキャッシュがない場合、必要なときに作成されます。
しかし、それにはインターネット接続が必要ですが、singularityキャッシュ作成時にインターネットへの接続がきれると、ワークフロー全体が止まってしまいます。

インターネット接続が切断されている場合、以下のようにして作成できます。

#### qlogin に関する注意点

この作業を行う際に、遺伝研の場合は、24GB程度必要なことがあります。

参考情報：
[遺伝研スパコンでDFASTを動かす \- Qiita](https://qiita.com/nigyta/items/e1de21f6ece65d69ec1d)

```console
qlogin -l mem_req=24g,s_vmem=24G
```

#### Singulairtyキャッシュ作成用スクリプト取得

```console
cd bact_genome
curl -O https://raw.githubusercontent.com/manabuishii/cwl-samples-2023/main/scripts/create_singularity_cache_1file.sh
chmod +x create_singularity_cache_1file.sh
```

#### Singularityキャッシュ作成スクリプトの実行

```bash
CWL_SINGULARITY_CACHE=~/.singularity_cache_dfast ./create_singularity_cache_1file.sh cwl/tool/dfast/dfast.cwl
CWL_SINGULARITY_CACHE=~/.singularity_cache_dfast ./create_singularity_cache_1file.sh cwl/tool/dfastqc/dfastqc.cwl
```

## 実行方法

### cwltool

単独のマシンで実行するときは以下のようにします。

```bash
CWL_SINGULARITY_CACHE=~/.singularity_cache_dfast cwltool dfast-filelist.cwl jobfile.yaml
```

### toil

分散環境を使って実行するには以下のようにします。
以下は、grid_engineの例です。

```bash
CWL_SINGULARITY_CACHE=~/.singularity_cache_dfast toil-cwl-runner --batchSystem grid-engine --jobStore jobsotre_dfast --output output_dfast dfast-filelist.cwl jobfile.yaml
```

## スクリプト

TODO: 分散シバンのインストール

```bash
#!/bin/bash

# MAXMEM
MAXMEM=8G
# 実際のメモリ、MAXMEM - 1 GBが推奨されます
ACTUALMEM=7G

# ジョブファイル
JOBFILE=dfastqc_GCA_under10M_ag.yaml
PREFIX=MAGoutput_dfastqc_218655/$(basename -s .yaml ${JOBFILE})
# CWL記述
CWLFILE=dfast_qc_filelist_0.5.7_2.cwl
DESCRIPTION="dfast_qc 0.5.7_2 toil"

ACCOUNTINGFILE=$PWD/${PREFIX}/accounting.txt
mkdir -p ${PREFIX}
mkdir -p ${PREFIX}/bin
cat << EOS >  ${PREFIX}/bin/qacct
#!/bin/bash
for i in \`seq 1 10\`
do
  touch ${ACCOUNTINGFILE}
  if /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@" &> /dev/null ; then
    break
  fi
  sleep 1
done
if /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@" &> /dev/null ; then
  /home/geadmin2/UGES/bin/lx-amd64/qacct -f ${ACCOUNTINGFILE} "\$@"
else
  /home/geadmin2/UGES/bin/lx-amd64/qacct "\$@"
fi
EOS
chmod 755  ${PREFIX}/bin/qacct
PATH=${PREFIX}/bin:${PATH}

# qacct用
tail -f /home/geadmin2/UGES/uges/common/accounting | grep ":${USER}:" > ${ACCOUNTINGFILE} &
TAILPROCESS=$!
echo ${TAILPROCESS} > ${PREFIX}/tail.process.pid.txt

# 情報のダンプ
NOW=$(date "+%Y%m%d%H%M%S")
NOWDIR=${PREFIX}/${NOW}
mkdir -p ${NOWDIR}
VERSIONFILE=${NOWDIR}/versions.txt
#
cwltool --version > ${VERSIONFILE}
toil-cwl-runner --version >> ${VERSIONFILE}
echo "python path" >>

 ${VERSIONFILE}
echo "    python $(which python)" >> ${VERSIONFILE}
echo "    python version $(python --version)" >> ${VERSIONFILE}
echo "    python sys.path $(python -c 'import sys; print(sys.path)')" >> ${VERSIONFILE}
echo "    python \$HOME  = $(python -c 'import os; print(os.path.expanduser("~"))')" >> ${VERSIONFILE}

source activate env_toil5
# Toil実行
time toil-cwl-runner --batchSystem grid-engine \
--singularity \
--noLinkImports \
--not-strict \
--workDir $PWD/toilwork \
--outdir ${PREFIX}/output \
--cleanWorkDir always \
--clusterStats ${PREFIX}/clusterStats_${NOW}.txt \
--jobStore ${PREFIX}/jobStore_${NOW} \
${CWLFILE} ${JOBFILE}

kill ${TAILPROCESS}

source deactivate
```

### 注意事項

- jobStoreは前のToil実行から残っている可能性があります。
  キャッシュを利用しないのであれば、それらを削除してから実行してください。

- MAXMEMは過去のToil実行で検出された最大メモリ使用量です。
  削除する場合は、実際のメモリ使用量を知る必要があります。

- ACTUALMEMはToilによって使用される実際のメモリです。

### その他

このスクリプトは、Toil実行の一部としてインストールされているSingularityおよびToilのバージョンを特定します。
また、cwltoolのバージョンも特定されます。また、cwltoolおよびToilのいくつかの実行に関する情報も収集されます。

このスクリプトは、Toil実行中にアカウンティングファイルをモニタリングし、ジョブの会計情報をコピーし、コピーが失敗した場合にリトライします。
また、最終的にアカウンティングファイルのモニタリングを停止します。 