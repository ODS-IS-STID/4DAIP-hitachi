# voxel-data-link-command

voxel-data-link-commandプロジェクトの簡単な説明をここに記載します。

## 目次

- [概要](#概要)
- [インストール](#インストール)
- [使い方](#使い方)
- [注意事項](#注意事項)
- [ライセンス](#ライセンス)

## 概要

登録した人口集中地区情報や標高情報等を、空間ボクセル情報としてDBに登録する機能です。

## インストール

このプロジェクトをローカル環境にインストールする手順を記載します。

1. git clone後

```bash
cd voxel-data-link-command

# プロジェクトのビルド
# ビルドすることで実行可能なjarファイルおよびクラスファイルを生成
./gradlew build  

# プロジェクトをビルドしてJARファイルを作成します。
./gradlew bootJar
```

## 使い方

プロジェクトの使い方や基本的な使用例を記載します。

1. application.ymlの修正
ボクセルのズーム率や生成する範囲等を指定してください
※[注意事項](#注意事項)参照

変更例

```
# databaseのURLに変更ください
    url: jdbc:postgresql://localhost:5432/td_aip?rewriteBatchedStatements=true

#　ボクセル生成における設定を変更してください（例 ズーム率、緯度、経度など）

# 実証
experiment:
  spatial-id:
    # ズーム率を設定ください。推奨20
    z: 20
  airspace:
    # ボクセル生成範囲を設定下さい
    # 緯度
    lat:
      # 最大：北
      max: 37.631955
      # 最小:南
      min: 37.591413
    # 経度
    lon:
      # 最大：東
      max: 140.9222
      # 最小：西
      min: 140.8898
    # 海抜高度
    elv:
      # 最大：高
      max: 200
      # 最小：低
      min: -1

```


2. 人口集中地区情報ボクセル生成処理

以下、コマンドで起動します。

```
java -jar voxel-data-link-command-0.0.1.jar --spring.config.location=application.yml -did ddb07cdf-ebb7-4ed5-bba6-6f5f25864a9e,fcdc9a82-71f5-4d5f-b370-b8a2374efe84,5c6c88f3-a464-4c8f-91b7-c5d39aab3d30,0e42676d-9459-4e53-bc90-2e44dbb4cab5
```

※UUID（以下赤文字）はdid_infoテーブルのdata_idカラムにあり、複数指定時の区切り文字は「,」

<span style="color: tomato;"> ddb07cdf-ebb7-4ed5-bba6-6f5f25864a9e,fcdc9a82-71f5-4d5f-b370-b8a2374efe84,5c6c88f3-a464-4c8f-91b7-c5d39aab3d30,0e42676d-9459-4e53-bc90-2e44dbb4cab5 </span>


3. 標高情報ボクセル生成処理

以下のコマンドを実行します。
※application.ymlは登録した標高情報の範囲内であることを確認

```
# 各自の環境に合わせて適宜変更ください
java -jar voxel-data-link-command-0.0.1.jar --spring.config.location=application.yml -dem
```

4. 3次元都市モデルボクセル生成処理

①UUIDリストの作成


例
- UUIIDリストのパス：/opt/3d-city-model-data-link/log/city-model-uuidlist.txt
- 接続先のDBホスト：localhost
- 接続先のDBポート：5432
- 接続先のDBユーザ：postgres
- 接続先のDB名：td_aip


以下のコマンドを実行します。


```
※psqlコマンド実行直後にパスワード入力あり
cd /opt/3d-city-model-data-link/log/
psql --host=localhost --port=5432 --username=postgres --password --dbname=td_aip -c "COPY (select data_id from td_aip.plateau_data_info) TO STDOUT" > citymodel_uuidlist.txt
```

②起動


以下のコマンドを実行します。

callcityvoxel.shはtoolフォルダにあります。

voxel-data-link-command-0.0.1.jarと同じフォルダで実行ください。

```
# 各自の環境に合わせて適宜変更ください(Windowsの場合は、Git Bashで起動)
bash callcityvoxel.sh /opt/3d-city-model-data-link/log/city-model-uuidlist.txt 100 | tee log/voxel-data-link-command.log
```
※人口集中地区ボクセル生成同様に、UUID指定での実行も可能  
　以下、コマンドを実行

```
java -jar voxel-data-link-command-0.0.1.jar --spring.config.location=application.yml -city ddb07cdf-ebb7-4ed5-bba6-6f5f25864a9e,fcdc9a82-71f5-4d5f-b370-b8a2374efe84,5c6c88f3-a464-4c8f-91b7-c5d39aab3d30,0e42676d-9459-4e53-bc90-2e44dbb4cab5
```

※UUID（以下赤文字）はplateau_infoテーブルのdata_idカラムにあり、複数指定時の区切り文字は「,」

<span style="color: tomato;"> ddb07cdf-ebb7-4ed5-bba6-6f5f25864a9e,fcdc9a82-71f5-4d5f-b370-b8a2374efe84,5c6c88f3-a464-4c8f-91b7-c5d39aab3d30,0e42676d-9459-4e53-bc90-2e44dbb4cab5 </span>

## 注意事項

プロジェクト使用時の注意事項を記載します。
- 人口集中地区情報や3次元都市モデル情報がボクセル情報を生成する範囲内であること
- 標高情報がボクセル生成範囲をカバーしていること

※満たしていない場合、ボクセル情報が生成されないため、注意が必要

## ライセンス

このプロジェクトのライセンス情報を記載します。

このプロジェクトは MIT ライセンスの下で公開されています。詳細については、LICENSE ファイルを参照してください。

