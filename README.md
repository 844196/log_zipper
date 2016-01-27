# LogZipper

[![Required Ruby](https://img.shields.io/badge/ruby-%3E%3D%202.2.0-red.svg)](#)
[![Travis branch](https://img.shields.io/travis/844196/log_zipper.svg)](https://travis-ci.org/844196/log_zipper)

LanScopeの出力する`ﾘｱﾙﾀｲﾑｲﾍﾞﾝﾄﾛｸﾞ01.csv`を変換し、終了時刻と稼働時間を計算したCSVを出力するスクリプト

## Usage

### 書式

```
log_zipper.rb [オプション] <入力ファイル1> <入力ファイル2>...
```

### オプション

|option                |description                                     |
|----------------------|------------------------------------------------|
|`--yaml=<PATH>`       |設定ファイルを指定して実行する                  |
|`--log-level=<LEVEL>` |実行中、出力するログのレベルを指定              |
|`--dry-run`           |実行結果をファイルに出力せず、シェル上に表示する|

### 使い方

実行すると、入力ファイルと同じディレクトリに`<入力ファイル名>_修正済み2.<入力ファイル拡張子>`が出力される

```shellsession
> ruby log_zipper.rb hogefuga.csv

> dir /b
hogefuga.csv
hogefuga_修正済み2.csv
```

*note:* 出力ファイルに付与されるサフィックスは`config.yml`で変更可能

## config.yml

TBD
