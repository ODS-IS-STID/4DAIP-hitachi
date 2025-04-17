#!/usr/bin/env python3

import datetime
import math

<<<<<<< HEAD
# P
# 北(緯度、LAT:大)
NORTH = 36.01
# 東(経度、LON:大)
EAST = 139.9
# 上(標高[m]、海抜高度、ALT:大)
# ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
HIGH = 150

# 南(緯度、LAT:小)
SOUTH = 35.99
# 西(経度、LON:小)
WEST = 139.8
# 下(標高[m]、海抜高度、ALT:小)
# ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
LOW = -20


# # CT
# # 北(緯度、LAT:大)
# NORTH = 37.666107
# # 東(経度、LON:大)
# EAST = 141.0577193
# # 上(標高[m]、海抜高度、ALT:大)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# HIGH = 150

# # 南(緯度、LAT:小)
# SOUTH = 37.491688
# # 西(経度、LON:小)
# WEST = 140.9842737
=======

# 北(緯度、LAT:大)
NORTH = 37.670251
# 東(経度、LON:大)
EAST = 140.9889
# 上(標高[m]、海抜高度、ALT:大)
# ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
HIGH = 50
# 南(緯度、LAT:小)
SOUTH = 37.66209263
# 西(経度、LON:小)
WEST = 140.9846125
# 下(標高[m]、海抜高度、ALT:小)
# ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
LOW = 0



# # P
# # 北(緯度、LAT:大)
# NORTH = 36.01
# # 東(経度、LON:大)
# EAST = 139.9
# # 上(標高[m]、海抜高度、ALT:大)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# HIGH = 150
# # 南(緯度、LAT:小)
# SOUTH = 35.99
# # 西(経度、LON:小)
# WEST = 139.8
>>>>>>> remotes/origin/develop
# # 下(標高[m]、海抜高度、ALT:小)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# LOW = -20

<<<<<<< HEAD
=======
# # CT(ATの南西：左下)
# # 北(緯度、LAT:大)
# NORTH = 37.61147
# # 東(経度、LON:大)
# EAST = 140.92845
# # 上(標高[m]、海抜高度、ALT:大)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# HIGH = 200
# # 南(緯度、LAT:小)
# SOUTH = 37.604984
# # 西(経度、LON:小)
# WEST = 140.9203
# # 下(標高[m]、海抜高度、ALT:小)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# LOW = 0

# # AT範囲
# # 北(緯度、LAT:大)
# NORTH = 37.670251
# # 東(経度、LON:大)
# EAST = 140.9889
# # 上(標高[m]、海抜高度、ALT:大)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# HIGH = 200
# # 南(緯度、LAT:小)
# SOUTH = 37.604984
# # 西(経度、LON:小)
# WEST = 140.9203
# # 下(標高[m]、海抜高度、ALT:小)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# LOW = -10

# # AT_ダム側
# # 北(緯度、LAT:大)
# NORTH = 37.641966
# # 東(経度、LON:大)
# EAST = 140.9259
# # 上(標高[m]、海抜高度、ALT:大)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# HIGH = 784.06
# # 南(緯度、LAT:小)
# SOUTH = 37.578868 
# # 西(経度、LON:小)
# WEST = 140.8679
# # 下(標高[m]、海抜高度、ALT:小)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# LOW = -1

# # AT_海岸線側
# # 北(緯度、LAT:大)
# NORTH =37.57403
# # 東(経度、LON:大)
# EAST = 141.02776
# # 上(標高[m]、海抜高度、ALT:大)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# HIGH = 200.0
# # 南(緯度、LAT:小)
# SOUTH = 37.56983
# # 西(経度、LON:小)
# WEST = 141.01362
# # 下(標高[m]、海抜高度、ALT:小)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# LOW = -1.0

# # 羽田空港
# # 北(緯度、LAT:大)
# NORTH = 35.578086
# # 東(経度、LON:大)
# EAST = 139.832976
# # 上(標高[m]、海抜高度、ALT:大)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# HIGH = 200
# # 南(緯度、LAT:小)
# SOUTH = 35.517085
# # 西(経度、LON:小)
# WEST = 139.747649
# # 下(標高[m]、海抜高度、ALT:小)
# # ※TABLE_NAME == TABLE_NAME_2Dの場合はコード内で0で上書きします
# LOW = 0

>>>>>>> remotes/origin/develop
# # RTF
# # 北(緯度、LAT:大)
# NORTH = 37.641666667
# # 東(経度、LON:大)
# EAST = 141.025000000154
# # 上(標高[m]、海抜高度、ALT:大)
# HIGH = 200
<<<<<<< HEAD
#
=======
>>>>>>> remotes/origin/develop
# # 南(緯度、LAT:小)
# SOUTH = 37.6250000002308
# # 西(経度、LON:小)
# WEST = 141.0
# # 下(標高[m]、海抜高度、ALT:小)
# LOW = 0

# Zoomレベル
<<<<<<< HEAD
ZOOM=20
=======
ZOOM=21
>>>>>>> remotes/origin/develop
# 高度方向が1mになるZoomレベル
ONE_M_ZOOM_LEVEL = 25
# 2Dのテーブル名
TABLE_NAME_2D = 'spatial_id_location_2d'
# 3Dのテーブル名
TABLE_NAME_3D = 'spatial_id_location_3d'
# テーブル名(TABLE_NAME_2DかTABLE_NAME_3Dのどちらか)
<<<<<<< HEAD
TABLE_NAME = TABLE_NAME_2D

=======
TABLE_NAME = TABLE_NAME_3D
>>>>>>> remotes/origin/develop

# 点→タイル番号
def point2tileNumber(lat, lon, alt, zoom, oneMZoomLevel):
    lat_rad = math.radians(lat)
    n = 2.0 ** zoom
    x = math.floor((lon + 180.0) / 360.0 * n)
    y = math.floor((1.0 - math.asinh(math.tan(lat_rad)) / math.pi) / 2.0 * n)
    f = math.floor(alt / (2.0 ** oneMZoomLevel) * n)
    return {'x': x, 'y': y, 'f': f}

# タイル番号→北西下
def tileNumber2NorthWestLow(zoom, f, x, y, oneMZoomLevel):
    n = 2.0 ** zoom
    lon = x / n * 360.0 - 180.0
    lat_rad = math.atan(math.sinh(math.pi * (1 - 2 * y / n)))
    lat = math.degrees(lat_rad)
    alt = f * (2.0 ** oneMZoomLevel) / n
    return {'lat': lat, 'lon': lon, 'alt': alt}

# タイル番号→北東上
def tileNumber2NorthEestHigh(zoom, f, x, y, oneMZoomLevel):
    return tileNumber2NorthWestLow(zoom, f+1, x+1, y, oneMZoomLevel)

# タイル番号→南西下
def tileNumber2SouthWestLow(zoom, f, x, y, oneMZoomLevel):
    return tileNumber2NorthWestLow(zoom, f, x, y+1, oneMZoomLevel)

# Insert文作成
def createInertSQL(zoom, low, high, west, east, south, north, oneMZoomLevel, tableName, srid, now):
    with open(f"insert_{tableName}_{now:%Y%m%d_%H%M%S}.sql", 'w', encoding='UTF-8') as file:
        for f in range(low, high + 1, 1):
            #print(f'low:{low}, high:{high}, f:{f}')
            for x in range(west, east + 1, 1):
                #print(f'west:{west}, east:{east}, x:{x}')
                # range(north, south + 1, 1)でnorthがsouthより小さいのは、
                # 緯度は南に行くと小さくなるが、タイルは南(y)にいくと大きくなるため
                for y in range(north, south + 1, 1):
                    #print(f'south:{south}, north:{north}, y:{y}')

                    # 1行目
#                    if f == low and x == west and y == north:
                    if x == west and y == north:
                        if tableName == TABLE_NAME_2D:
<<<<<<< HEAD
                            file.write(f";INSERT INTO {tableName}(spatial_id_z, spatial_id_x, spatial_id_y, voxel, spatial_id, voxel_6677) VALUES ")
                        else:
                            file.write(f";INSERT INTO {tableName}(spatial_id_z, spatial_id_f, spatial_id_x, spatial_id_y, voxel, spatial_id, voxel_6677) VALUES ")
=======
                            file.write(f"INSERT INTO {tableName}(spatial_id_z, spatial_id_x, spatial_id_y, voxel, spatial_id) VALUES ")
                        else:
                            file.write(f"INSERT INTO {tableName}(spatial_id_z, spatial_id_f, spatial_id_x, spatial_id_y, voxel, spatial_id) VALUES ")
>>>>>>> remotes/origin/develop
                        file.write('\n')
                    # 1行目以外
                    else:
                        file.write(',')

                    northEastHighPoint = tileNumber2NorthEestHigh(
                        zoom=zoom,
                        f=f,
                        x=x,
                        y=y,
                        oneMZoomLevel=oneMZoomLevel
                    )
                    southWestLowPoint = tileNumber2SouthWestLow(
                        zoom=zoom,
                        f=f,
                        x=x,
                        y=y,
                        oneMZoomLevel=oneMZoomLevel
                    )

                    query = ''
                    if tableName == TABLE_NAME_2D:
                        query = (
                            f"({zoom}, {x}, {y}"
                            ", ST_SetSRID(ST_MakeBox2D("
                            f"ST_MakePoint({southWestLowPoint['lon']},{southWestLowPoint['lat']})"
                            f", ST_MakePoint({northEastHighPoint['lon']},{northEastHighPoint['lat']}))"
                            f",{srid})"
<<<<<<< HEAD
                            f",'{zoom}/null/{x}/{y}'"
                            ", ST_Transform(ST_SetSRID(ST_MakeBox2D("
                            f"ST_MakePoint({southWestLowPoint['lon']},{southWestLowPoint['lat']})"
                            f", ST_MakePoint({northEastHighPoint['lon']},{northEastHighPoint['lat']}))"
                            f",{srid}),6677))"
=======
                            f",'{zoom}/null/{x}/{y}')"
>>>>>>> remotes/origin/develop
                        )
                    else:
                        query = (
                            f"({zoom}, {f}, {x}, {y}"
                            ", ST_SetSRID(ST_3DMakeBox("
                            f" ST_MakePoint({southWestLowPoint['lon']},{southWestLowPoint['lat']},{southWestLowPoint['alt']})"
<<<<<<< HEAD
                            f",ST_MakePoint({northEastHighPoint['lon']},{northEastHighPoint['lat']},{northEastHighPoint['alt']} - 0.001))"
                            f",{srid})"
                            f",'{zoom}/{f}/{x}/{y}'"
                            ", ST_Transform(ST_SetSRID(ST_3DMakeBox("
                            f" ST_MakePoint({southWestLowPoint['lon']},{southWestLowPoint['lat']},{southWestLowPoint['alt']})"
                            f",ST_MakePoint({northEastHighPoint['lon']},{northEastHighPoint['lat']},{northEastHighPoint['alt']} - 0.001))"
                            f",{srid}),6677))"
=======
                            f",ST_MakePoint({northEastHighPoint['lon']},{northEastHighPoint['lat']},{northEastHighPoint['alt']} - 0.00000000000001))"
                            f",{srid})"
                            f",'{zoom}/{f}/{x}/{y}')"
>>>>>>> remotes/origin/develop
                        )

                    file.write(query)
                    file.write('\n')
<<<<<<< HEAD
=======
            file.write(" ON CONFLICT DO NOTHING;\n")
>>>>>>> remotes/origin/develop


def main(northEastHighPoint, southWestLowPoint, zoom, oneMZoomLevel, tableName, srid, now):

    # 範囲を取得
    northEastHighTile = point2tileNumber(
        lat=northEastHighPoint['lat'],
        lon=northEastHighPoint['lon'],
        alt=northEastHighPoint['alt'],
        zoom=zoom,
        oneMZoomLevel=oneMZoomLevel)
<<<<<<< HEAD
    print(f"北東上(上東北)の空間ID：{zoom}/{northEastHighTile['f']}/{northEastHighTile['x']}/{northEastHighTile['y']}")
=======
    if TABLE_NAME == TABLE_NAME_2D:
        print(f"北東上(上東北)の空間ID：{zoom}/null/{northEastHighTile['x']}/{northEastHighTile['y']}")
    else:
        print(f"北東上(上東北)の空間ID：{zoom}/{northEastHighTile['f']}/{northEastHighTile['x']}/{northEastHighTile['y']}")
>>>>>>> remotes/origin/develop
    # print(northEastHighTile)

    southWastLowTile = point2tileNumber(
        lat=southWestLowPoint['lat'],
        lon=southWestLowPoint['lon'],
        alt=southWestLowPoint['alt'],
        zoom=zoom,
        oneMZoomLevel=oneMZoomLevel)
<<<<<<< HEAD
    print(f"南西下(下西南)の空間ID：{zoom}/{southWastLowTile['f']}/{southWastLowTile['x']}/{southWastLowTile['y']}")
=======
    if TABLE_NAME == TABLE_NAME_2D:
        print(f"南西下(下西南)の空間ID：{zoom}/null/{southWastLowTile['x']}/{southWastLowTile['y']}")
    else:
        print(f"南西下(下西南)の空間ID：{zoom}/{southWastLowTile['f']}/{southWastLowTile['x']}/{southWastLowTile['y']}")
>>>>>>> remotes/origin/develop
    # print(southWastLowTile)

    createInertSQL(
        zoom=zoom,
        low=southWastLowTile['f'],
        high=northEastHighTile['f'],
        west=southWastLowTile['x'],
        east=northEastHighTile['x'],
        south=southWastLowTile['y'],
        north=northEastHighTile['y'],
        oneMZoomLevel=oneMZoomLevel,
        tableName=tableName,
        srid=srid,
        now=now)

if __name__ == '__main__':
    import logging
    logging.basicConfig()

    # SRID
    #6697:測地系＝JGD2011、座標系＝地理座標系、標高(SRID:6695:日本測地系2011における高度)
    #6677:測地系＝JGD2011、座標系＝平面直角座標系(系番号=IX)、高度の指定なし
    #6668:測地系＝JGD2011、座標系＝地理座標系、高度の指定なし
    #4326:測地系＝世界測地系(WGS84)、座標系＝地理座標系、高度の指定なし
    SRID = 0
    if TABLE_NAME == TABLE_NAME_2D:
        SRID = 6668
        HIGH = 0
        LOW = 0
    else:
        SRID = 6697

    northEastHighPoint = {'lat': NORTH, 'lon': EAST, 'alt': HIGH}
    southWestLowPoint = {'lat': SOUTH, 'lon': WEST, 'alt': LOW}
    t_delta = datetime.timedelta(hours=9)
    jst = datetime.timezone(t_delta, 'JST')
    now = datetime.datetime.now(jst)
    main(
        northEastHighPoint=northEastHighPoint,
        southWestLowPoint=southWestLowPoint,
        zoom=ZOOM,
        oneMZoomLevel=ONE_M_ZOOM_LEVEL,
        tableName=TABLE_NAME,
        srid=SRID,
        now=now)
