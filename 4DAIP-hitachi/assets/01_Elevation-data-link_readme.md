# Elevation-data-link

Elevation-data-linkプロジェクトの簡単な説明をここに記載します。
4次元空間情報基盤に標高情報のファイルを読み込んでDBに登録する機能です。

## 目次

- [概要](#概要)
- [インストール](#インストール)
- [使い方](#使い方)
- [ライセンス](#ライセンス)

## 概要

標高情報のファイルを読み込んでDBに登録する機能です。

## インストール

このプロジェクトをローカル環境にインストールする手順を記載します。

1. git clone後　実行可能なjarファイルの作成

```bash
cd Elevation-data-link

# プロジェクトのビルド
# ビルドすることで実行可能なjarファイルおよびクラスファイルを生成
./gradlew build  

# 「bootjar」タスクは実行可能なjarファイルを生成
./gradlew bootJar
```

2. 標高データダウンロード

以下より数値標高モデルをダウンロード

[基盤地図情報　ダウンロードサービス](https://fgd.gsi.go.jp/download/menu.php)


## 使い方

プロジェクトの使い方や基本的な使用例を記載します。

1. 標高データ配置

標高データをサーバの任意のフォルダに配置します。（例：dem）


2. application.ymlの修正

application.ymlファイルの中身を適宜変更ください。

変更例

```
# databaseのURLに変更ください
url: jdbc:postgresql://localhost:5432/td_aip?rewriteBatchedStatements=true

# 各自対応するDEMデータに形式を合わせてください
  #1mメッシュ
  #DemFileNamePattern: ".*DEM1A.*\\.xml"
  #5mメッシュ
  DemFileNamePattern: ".*DEM5A.*\\.xml"

#作業用ディレクトリを指定ください
  GeoTiffOutputPath: "C:\\temp\\geotiff"
  SqlOutputPath: "C:\\temp\\sql"

```


3. 作成されたjarファイルを実行

```
# 各自の環境に合わせて適宜変更ください 
# ()内は不要な場合がございます
java -classpath .:/usr/share/java/gdal.jar (-Djava.library.path=/usr/lib/jni) -jar Elevation-data-link-0.0.1.jar --spring.config.location-application.yml ~/dem
```


## ライセンス

このプロジェクトのライセンス情報を記載します。

このプロジェクトは MIT ライセンスの下で公開されています。詳細については、LICENSE ファイルを参照してください。

