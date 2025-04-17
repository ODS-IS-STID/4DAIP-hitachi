<!DOCTYPE html>
<html>
<head>

<h2 id="%EF%BC%91%E6%A6%82%E8%A6%81">１．概要</h2>
<p>４次元時空間情報基盤を構成する各プロジェクトファイルです。</p>
<ul>
<li>
<p>メインプロジェクト</p>
<ul>
<li>Elevation-data-link
<ul>
<li>標高データを登録する</li>
</ul>
</li>
<li>DID-data-link
<ul>
<li>人口集中地区データを登録する</li>
</ul>
</li>
<li>3d-city-model-data-link
<ul>
<li>３次元都市モデルデータを登録する</li>
</ul>
</li>
<li>voxel-data-link-command
<ul>
<li>標高、人口集中地区、３次元都市モデルからボクセルデータを作成する</li>
</ul>
</li>
<li>drone-domain-api-service
<ul>
<li>ドローン領域API。４次元時空間情報基盤　アーキテクチャガイドライン（β版）を参考に構築したＡＰＩ
　  （https://www.ipa.go.jp/digital/architecture/guidelines/4dspatio-temporal-guideline.html）</li>
</ul>
</li>
</ul>
</li>
<li>
<p>サブプロジェクト</p>
<p>サブプロジェクトはメインプロジェクトと同一フォルダでビルドする必要があります。</p>
<ul>
<li>3d-aip-common
<ul>
<li>共通ライブラリ</li>
</ul>
</li>
<li>3d-api-dadc-common
<ul>
<li>ドローン領域APIにおけるボクセル情報取得に使用</li>
</ul>
</li>
<li>voxel-data-link
<ul>
<li>ボクセルデータ生成における共通ライブラリとして使用</li>
</ul>
</li>
<li>mobility-integration-manage
<ul>
<li>ドローン領域APIにおけるボクセル情報検索サービスに使用</li>
</ul>
</li>
</ul>
</li>
</ul>
<h2 id="%EF%BC%92%E5%89%8D%E6%8F%90%E7%92%B0%E5%A2%83">２．前提環境</h2>
<p>本環境はAWS環境構成、EC2にはubuntuOSを前提に作成されています。</p>
<p>各プロジェクト間の関係は図を参照してください。</p>
<p><img src="../assets/アーキテクチャ.png" alt=""></p>
<h2 id="%EF%BC%93%E3%83%87%E3%83%BC%E3%82%BF%E3%83%99%E3%83%BC%E3%82%B9%E4%BD%9C%E6%88%90">３．データベース作成</h2>
<ol>
<li>関連OSSインストール</li>
</ol>
<pre><code>postgresql16以降のバージョン推奨
postgis3.4以降のバージョン推奨
python3系以降のバージョン推奨
</code></pre>
<ol start="2">
<li>初期テーブル作成(例)</li>
</ol>
<p>Database作成</p>
<pre class="hljs"><code><div>    # ※td_aip 部分はプログラムのymlファイルで指定する必要があるため、注意
    CREATE DATABASE td_aip
	WITH
	OWNER = postgres
	ENCODING = ‘UTF8’
	LOCALE_PROVIDER = ‘libc’
	IS_TEMPLATE = False;
</div></code></pre>
<p>schema作成</p>
<pre class="hljs"><code><div>    # ※td_aip 部分はプログラムのymlファイルで指定する必要があるため、注意
    CREATE SCHEMA td_aip
	AUTHORIZATION postgres;
</div></code></pre>
<p>table作成</p>
<ul>
<li>
<p>以下<a href="../assets/3d_aip_create_table.sql">SQL</a>を実行する</p>
<ol start="3">
<li>初期データ作成</li>
</ol>
</li>
</ul>
<p>①以下をローカルディレクトリに配置</p>
<p><a href="../tools/createInsertQueryForSpaceIdLocation">空間ID位置テーブル作成用ツール</a></p>
<p>②空間ID位置2Dテーブル用のINSERT文ファイルを作成</p>
<p>以下コマンドを実行</p>
<pre class="hljs"><code><div># 作業ディレクトリに移動
cd /createInsertQueryForSpaceIdLocation

# 起動プログラムファイルを編集
vi createInsertQueryForSpaceIdLocation.py
</div></code></pre>
<p>createInsertQueryForSpaceIdLocation.py変更箇所</p>
<pre class="hljs"><code><div>
# 作成するボクセルの範囲を指定してください。以下例
# 北(緯度、LAT:大)
NORTH = 37.641666667
# 東(経度、LON:大)
EAST = 141.025000000154
# 上(標高[m]、海抜高度、ALT:大)
HIGH = 200

# 南(緯度、LAT:小)
# SOUTH = 37.6250000002308
# 西(経度、LON:小)
WEST = 141.0
# 下(標高[m]、海抜高度、ALT:小)
LOW = 0

# Zoomレベル
ZOOM=20
# 高度方向が1mになるZoomレベル
ONE_M_ZOOM_LEVEL = 25
# 2Dのテーブル名
TABLE_NAME_2D = 'spatial_id_location_2d'
# 3Dのテーブル名
TABLE_NAME_3D = 'spatial_id_location_3d'
# テーブル名(TABLE_NAME_2DかTABLE_NAME_3Dのどちらか)
TABLE_NAME = TABLE_NAME_2D

</div></code></pre>
<p>起動プログラムを実行</p>
<pre class="hljs"><code><div>python3 createInsertQueryForSpaceIdLocation.py
</div></code></pre>
<p>③作成されたInsertファイルを実行</p>
<pre class="hljs"><code><div>psql -f insert_spatial_id_location_2d_20XXXXXX_XXXXXX.sql -h localhost -d td_aip -U postgres
</div></code></pre>
<p>④空間ID位置3Dテーブル用のINSERT文ファイルを作成</p>
<p>以下コマンドを実行</p>
<pre class="hljs"><code><div># 作業ディレクトリに移動
cd /createInsertQueryForSpaceIdLocation

# 起動プログラムファイルを編集
vi createInsertQueryForSpaceIdLocation.py
</div></code></pre>
<p>createInsertQueryForSpaceIdLocation.py変更箇所</p>
<pre class="hljs"><code><div>
# 作成するボクセルの範囲を指定してください。以下例
# 北(緯度、LAT:大)
NORTH = 37.641666667
# 東(経度、LON:大)
EAST = 141.025000000154
# 上(標高[m]、海抜高度、ALT:大)
HIGH = 200

# 南(緯度、LAT:小)
# SOUTH = 37.6250000002308
# 西(経度、LON:小)
WEST = 141.0
# 下(標高[m]、海抜高度、ALT:小)
LOW = 0

# Zoomレベル
ZOOM=20
# 高度方向が1mになるZoomレベル
ONE_M_ZOOM_LEVEL = 25
# 2Dのテーブル名
TABLE_NAME_2D = 'spatial_id_location_2d'
# 3Dのテーブル名
TABLE_NAME_3D = 'spatial_id_location_3d'
# テーブル名(TABLE_NAME_2DかTABLE_NAME_3Dのどちらか)
TABLE_NAME = TABLE_NAME_3D

</div></code></pre>
<p>起動プログラムを実行</p>
<pre class="hljs"><code><div>python3 createInsertQueryForSpaceIdLocation.py
</div></code></pre>
<p>⑤作成されたInsertファイルを実行</p>
<pre class="hljs"><code><div>psql -f insert_spatial_id_location_3d_20XXXXXX_XXXXXX.sql -h localhost -d td_aip -U postgres
</div></code></pre>
<h2 id="%EF%BC%94javagdal%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB">４．JAVA/gdalインストール</h2>
<pre><code>java17以降のバージョン推奨
gdal3系以降のバージョン推奨
</code></pre>
<h2 id="%EF%BC%95%E5%90%84%E3%83%97%E3%83%AD%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%81%AE%E3%83%93%E3%83%AB%E3%83%89%E3%81%A8%E5%AE%9F%E8%A1%8C%E6%96%B9%E6%B3%95">５．各プロジェクトのビルドと実行方法</h2>
<p>各プロジェクトreadme参照</p>
<ul>
<li><a href="../assets/01_Elevation-data-link_readme.md">Elevation-data-link</a></li>
<li><a href="../assets/02_DID-data-link_readme.md">DID-data-link</a></li>
<li><a href="../assets/03_3d-city-model-data-link_readme.md">3d-city-model-data-link</a></li>
<li><a href="../assets/04_voxel-data-link-command_readme.md">voxel-data-link-command</a></li>
<li><a href="../assets/05_drone-domain-api-service_readme.md">drone-domain-api-service</a></li>
</ul>

<h2 id="%EF%BC%96%E8%91%97%E8%80%85">6．著者</h2>
<p>日立製作所</p>

<p>======================================================================================================================<br>
PostgreSQLは、PostgreSQL Community Association of Canadaのカナダにおける登録商標およびその他の国における商標です。<br>
Javaは、Oracle Corporationおよびその子会社、関連会社の米国およびその他の国における登録商標です。<br>
Pythonは、Python Software Foundationの登録商標です。<br>
Amazon EC2 およびその他のAWS 商標は、米国およびその他の諸国におけるAmazon.com,Inc.またはその関連会社の商標です。<br>
Ubuntuは、Canonical Ltd.の登録商標です。<br>
======================================================================================================================</p>

</body>
</html>
