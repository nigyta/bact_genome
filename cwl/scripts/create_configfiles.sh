#!/bin/bash
# 
# 引数１で渡されたディレクトリにある拡張子txtのファイルが対象になる。
# ファイルの中身は、入力となるファイルのパスが１行１ファイルで書かれている
# 出力されるファイルは、入力となるファイルの.txtを除いた部分を使用した.yamlになる
#
# The file with the extension txt in the directory passed in argument 1 is the target.
# The contents of the file will be the path to the input file, one file per line.
# The output file will be a .yaml using the part of the input file without the .txt extension
INPUTFILELISTDIR=$1


for FILE in $(ls ${INPUTFILELISTDIR}/*.txt)
do
  ls -l ${FILE}
  BASENAME=$(basename ${FILE} .txt)
  echo ${BASENAME}
  CONFIGFILE=dfast_dfastqc_${BASENAME}.yaml
  cat dfast_dfastqc_template.yaml > ${CONFIGFILE}
  echo "genome_list:" >> ${CONFIGFILE}
  for LINE in $(cat ${FILE})
  do
cat << EOS >> ${CONFIGFILE}
    - class: File
      path: ${LINE}
EOS
  done
done
