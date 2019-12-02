# NGS解析教本 バクテリアゲノム解析

## 本文で紹介したコマンドについて
  Jupyter notebook 形式のファイル [analysis.ipynb](analysis.ipynb) に解析の一連の手順を掲載しています。また、ダウンロードして Jupyter notebookからファイルを開くことでインタラクティブに解析を行うことができます。

### ファイルのダウンロード方法  
  次のコマンドで本サイトのファイルをダウンロードできます。`bact_genome` という名称でカレントディレクトリにダウンロードされます。
  ```
  git clone https://github.com/nigyta/bact_genome.git
  ```
  
### Jupyter notebook インストール方法
  下記の手順でインストール可能です。また、Jupyter notebookで __bashコマンドを実行するために bash カーネルを追加__ する必要があります。
  ```
  # Jupyter のインストール
  pip install jupyter

  # bashカーネルのインストール
  pip install bash_kernel
  python -m bash_kernel.install
  ```



### Jupyter notebook 起動方法
  ```
  jupyter notebook
  ```
  起動後、ブラウザが立ち上がりますので画面から analysis.ipynb を選び開いてください。  
  shift-Enter を押していくことで順に実行できます。
## cwl によるワークフローの実行
[cwl](cwl) ディレクトリの [README](cwl/README.md) をご参照ください。

