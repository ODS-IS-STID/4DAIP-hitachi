# DID-data-link

DID-data-linkプロジェクトの簡単な説明をここに記載します。

## 目次

- [概要](#概要)
- [インストール](#インストール)
- [使い方](#使い方)
- [ライセンス](#ライセンス)

## 概要

人口集中地区情報のファイルを読み込んでDBに登録する機能です。

## インストール

このプロジェクトをローカル環境にインストールする手順を記載します。

1. git clone後　jarファイルの作成

```bash
cd DID-data-link

# プロジェクトのビルド
# ビルドすることで実行可能なjarファイルおよびクラスファイルを生成
./gradlew build  

# 「bootjar」タスクは実行可能なjarファイルを生成
./gradlew bootJar
```




2. 人口集中地区データダウンロード

以下よりDID人口集中地区（ポリゴン）をダウンロード

[国土数値情報ダウンロードサイト](https://nlftp.mlit.go.jp/ksj/index.html)


## 使い方

プロジェクトの使い方や基本的な使用例を記載します。

1. 人口集中地区データの配置

人口集中地区データをサーバの任意のフォルダに配置します。（例：did）


2. application.ymlの修正

application.ymlファイルの中身を適宜変更ください。

変更例

```
# databaseのURLに変更ください
url: jdbc:postgresql://localhost:5432/td_aip?rewriteBatchedStatements=true
```


3. 作成されたjarファイルを実行

```
# 各自の環境に合わせて適宜変更ください 
# ()内は不要な場合がございます
java -classpath .:/usr/share/java/gdal.jar (-Djava.library.path=/usr/lib/jni) -jar Did-data-link-0.0.1.jar --spring.config.location=application.yml ~/did/XXX-XX_XX_DID.geojson
```
※以下エラーが発生する場合、GDAL Command Pronptで実行を試す
```
# Javaアプリケーションがネイティブライブラリ gdalalljni を見つけられない場合に発生するエラー  
java.lang.UnsatisfiedLinkError: no gdalalljni in java.library.path:
```
## ライセンス

このプロジェクトのライセンス情報を記載します。

このプロジェクトは MIT ライセンスの下で公開されています。詳細については、LICENSE ファイルを参照してください。

