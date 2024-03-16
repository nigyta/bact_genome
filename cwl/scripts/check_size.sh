#!/bin/bash

# ファイルリストが格納されているテキストファイルのパス
filelist="exist.txt"

# 比較するサイズ（バイト単位）
size_threshold=31457280 # 30MB

# 出力ファイル
smaller_than="smaller_than.txt"
larger_than="larger_than.txt"

# 出力ファイルの初期化
> "$smaller_than"
> "$larger_than"

# 一時ディレクトリの作成
temp_dir=$(mktemp -d)

# リストにある各ファイルをチェック
while read -r file; do
    if [ -f "$file" ]; then
        # 一時ファイルのパス
        temp_file="$temp_dir/$(basename "$file" .gz)"

        # ファイルを一時的に解凍
        gunzip -c "$file" > "$temp_file"

        # 解凍後のサイズを取得
        size=$(stat -c%s "$temp_file")

        # サイズに応じてファイルを分類
        if [ "$size" -le "$size_threshold" ]; then
            echo "$file" >> "$smaller_than"
        else
            echo "$file" >> "$larger_than"
        fi

        # 一時ファイルを削除
        rm "$temp_file"
    fi
done < "$filelist"

# 一時ディレクトリを削除
rm -r "$temp_dir"

