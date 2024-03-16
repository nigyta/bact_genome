#!/bin/bash

# 入力ファイル名と出力ファイル名を設定
input_file="filelist.txt"
error_output_file="error.txt"
exist_output_file="exist.txt"
zerobyte_output_file="zerobyte.txt"
gunzip_fail_file="gunzipfail.txt"

# ファイルが存在しない場合にエラーを出力する関数
check_file_existence() {
  if [ ! -f "$1" ]; then
    echo "$1" >> "$error_output_file"
  elif [ ! -s "$1" ]; then
    echo "$1" >> "$zerobyte_output_file"
  else
    gunzip -c "$1" > /dev/null
    RET=$?
    if [ ! ${RET} -eq 0 ]; then
      # 失敗時の処理をここに追加
      echo "$1" >> "$gunzip_fail_file"
    else
      # 成功時の処理をここに追加
      echo "$1" >> "$exist_output_file"
    fi


  fi
}

# 出力ファイルを初期化
> "$error_output_file"
> "$exist_output_file"
> "$zerobyte_output_file"
> "$gunzip_fail_file"

# 入力ファイルを行ごとに処理
while IFS= read -r line; do
  # 行を空白で区切り、2番目の要素を取得
  second_element=$(echo "$line" | awk '{print $2}')
  first_element=$(basename ${second_element})
  
  # 2番目の要素.txtが存在するかチェック
  check_file_existence "$second_element/${first_element}_genomic.fna.gz"
  #echo "$check_file_existence"
done < "$input_file"
