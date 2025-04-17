# drone-domain-api-service

drone-domain-api-serviceプロジェクトの簡単な説明をここに記載します。

## 目次

- [概要](#概要) 
- [インストール](#インストール)
- [使い方](#使い方)
- [ライセンス](#ライセンス)


## 概要

4次元空間情報基盤が保持する飛行可能な空域情報の提供や登録、削除を行う機能です。

## インストール

このプロジェクトをローカル環境にインストールする手順を記載します。

1. git clone後

```bash
cd drone-domain-api-service

# プロジェクトのビルド
# ビルドすることで実行可能なjarファイルおよびクラスファイルを生成
./gradlew build  

# 「bootjar」タスクは実行可能なjarファイルを生成
./gradlew bootJar
```

## 使い方

プロジェクトの使い方や基本的な使用例を記載します。

1. application.ymlの修正


変更例

```
server:
  # RESTコントローラのポート
  port: 18080



# databaseのURLに変更ください
    url: jdbc:postgresql://localhost:5432/td_aip?rewriteBatchedStatements=true


# 実証
experiment:
  airspace:
    # ボクセル生成範囲を指定下さい
    # 緯度
    lat:
      # 最大：北
      max: 37.650251
      # 最小:南
      min: 37.620984
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

  # 空間ID位置3Dテーブル用のINSERT文ファイル作成時のログ参照
  # 空間ID
  spatialId:
    # ズーム
    z:
      # 最大
      max: 20
      # 最小
      min: 20
    # 高度方向
    f:
      # 最大：高
      max: 6
      # 最小：低
      min: 0
    # 経度方向
    x:
      # 最大：東
      max: 934947
      # 最小：西
      min: 934748
    # 緯度方向
    y:
      # 最大：南
      max: 405922
      # 最小：北
      min: 405681
```

2. (Linuxの場合)serviceの作成


/etc/systemd/system/の下（または/lib/systemd/system/でも可）に以下ファイルを作成します。

ファイル名：drone-domain-api-service.service

※各OSによって異なります

```
[Unit]
Description=application to manage drone-domain-api-service
After=syslog.target

[Service]
User=root
ExecStart=/opt/drone-domain-api-service/drone-domain-api-service-0.0.1.jar
# 自動起動
#Restart=always
# 手動起動のみ
Restart=no
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target

```

その後、以下コマンドでサービス登録します。

```
# 自動起動on
systemctl enable drone-domain-api-service
```

以下コマンドで起動します。

```
# 起動
systemctl start drone-domain-api-service
```
　→　起動確認後、4.に移動してください。

3. (Windowsの場合)作成されたjarファイルを実行

```
# 各自の環境に合わせて適宜変更ください
java -classpath "C:\Program Files\GDAL\java\gdal.jar" -jar C:\Users\dpls01\work\git\DADC\drone-domain-api-service\build\libs\drone-domain-api-service-0.0.1.jar --spring.config.location="C:\Users\dpls01\work\git\DADC\mobility-integration-manage-command\src\main\resources\application.yml",application.yml"
```

※ドローン領域APIにおける空間ボクセル情報検索処理に使用するため、モビリティ統合データ管理機能の設定ファイルも参照とする必要があります



4. 実行方法

①　サーバへの接続（ログイン）
接続、認証を行いトークンを取得します。  
user情報は適宜データベースを確認ください。

実行例

```
curl -H "Content-Type: application/json" localhost:18080/common_service/loc_connect -d '{"userId":"ut01", "organizationId":"org01", "password":"tdaip"}' -vN
```
powershellの場合
```
Invoke-WebRequest -Uri 'http://localhost:18080/common_service/loc_connect' -Method Post -ContentType 'application/json' -Body '{"userId":"ut01", "organizationId":"org01", "password":"tdaip"}'
```

取得したBearerトークンは以降のコマンドで置き換えてください。

②　空域登録  
各種形状の空域空間を空間ID群で登録します。

実行例

```
curl -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdDAxIiwiZXhwIjoxNzE4NzU5NjA4fQ.FTYsjqY6Z0tacaPwwNgit9l88x8pF853mm-7VJ-RJyo" -H "Tdaip-User-Id: ut01" localhost:18080/common_service/loc_put_airspace  -d '{"objectId":"0", "areas":[{"spatialId":"20/4/934859/405830"}], "value":{"airArea":{"attr":"P","reference":"testdata"}}}' -vN
```

③　空域予約  
飛行計画（各種形状の空域空間）を空間ID群で登録します。

実行例

```
curl -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdDAxIiwiZXhwIjoxNzE4NzU5NjA4fQ.FTYsjqY6Z0tacaPwwNgit9l88x8pF853mm-7VJ-RJyo" -H "Tdaip-User-Id: ut01" localhost:18080/common_service/loc_put_reserve_area -d '{"objectId":"0", "areas":[{"spatialId":"20/3/934859/405830"}], "value":{"period":{"startTime":"1699405200","endTime":"1699408800"}, "reference":"test-reserve"}}' -vN
```

④　空域情報取得  
ユーザが登録した空域のID(object_id)を取得します。

実行例

```
curl -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdDAxIiwiZXhwIjoxNzE4NzU5NjA4fQ.FTYsjqY6Z0tacaPwwNgit9l88x8pF853mm-7VJ-RJyo" -H "Tdaip-User-Id: ut01" localhost:18080/common_service/loc_select_airspace -d '{"areas":[{"spatialId":"20/3/934859/405830"},{"spatialId":"20/4/934859/405830"}], "period":{"startTime":"1699405000","endTime":"1699409000"}}' -vN
```


⑤　空域削除  
ユーザが登録した空域を削除します。

実行例

```
curl -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdDAxIiwiZXhwIjoxNzE4NzU5NjA4fQ.FTYsjqY6Z0tacaPwwNgit9l88x8pF853mm-7VJ-RJyo" -H "Tdaip-User-Id: ut01" localhost:18080/common_service/loc_delete -d '{"objectIds":["1","2"]}' -vN
```


⑥　空間情報取得  
リスク値などの空間情報の値を取得します。

実行例

```
curl -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdDAxIiwiZXhwIjoxNzE5MTA4MTAzfQ.u7z52LX4X9StplIE0REuYzEBKprFpMv5TR6sFEYdGMo" -H "Tdaip-User-Id: ut01" localhost:18080/common_service/loc_get_value -d '{"areas":[{"spatialId":"20/0/934927/405800"}], "requestTypes": ["WEATHER"], "period":{"startTime":"1740548800","endTime":"1743548800"}}' -vN
```

⑦飛行可能な空域取得  
指定した領域および時刻で飛行可能な空域空間の空間ID群を取得します。  
空域空間の値の取得には空間情報取得「GetValue()」を使用してください。

実行例

```
curl -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdDAxIiwiZXhwIjoxNzE4NzU5NjA4fQ.FTYsjqY6Z0tacaPwwNgit9l88x8pF853mm-7VJ-RJyo" -H "Tdaip-User-Id: ut01" localhost:18080/common_service/loc_select_airspace_arrangement -d '{"areas":[{"spatialId":"20/5/934860/405830"}], "period":{"startTime":"1740548800","endTime":"1743548800"}}' -vN
```

⑧　飛行可能な空域のストリームによる取得  
指定した領域および時刻で飛行可能な空域空間の空間ID群をストリームで取得します。  
次のようなケースに利用してください。
- 大量のデータを分割して取得
- 変化を取得

実行例

```
curl -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdDAxIiwiZXhwIjoxNzE5ODg1NTYyfQ._L5JXLJTxOOPi_V_909ZhHScxqIWA20F61xs1wggiDs" -H "Tdaip-User-Id: ut01" localhost:18080/common_service/loc_select_airspace_arrangement_stream -d '{"areas":[{"spatialId":"20/5/934860/405830"}], "period":{"startTime":"1740548800","endTime":"1743548800"}, "streamRequestType":"DIVIDE"}' -vN
```

## ライセンス

このプロジェクトのライセンス情報を記載します。

このプロジェクトは MIT ライセンスの下で公開されています。詳細については、LICENSE ファイルを参照してください。

