import sys
import logging
import math
import time

import grpc
import SpatialId_pb2
import SpatialId_pb2_grpc

from SpatialId.shape import cylinders
from SpatialId.shape import polygons
from SpatialId.shape import point
from SpatialId.common.object.point import Triangle as SpatialTriangle
from SpatialId.common.object.point import Point as SpatialPoint
from SpatialId.common.object.enum import Point_Option
from SpatialId import logger as SpatialLogger
from concurrent import futures
from functools import cache

class SpatialIdServicer(SpatialId_pb2_grpc.SpatialIdServicer):

    def FGetSpatialIdsOnPolygons(self, request, context):
        if request.crs == -1:
            spatialIds = polygons.f_get_spatial_ids_on_polygons(
                self.createTriangles(request.barrierTraiangles), 
                self.createTriangles(request.spaceTriangles)
                , request.zoom, needs_closed_checking=False)
        else:
            spatialIds = polygons.f_get_spatial_ids_on_polygons(
                self.createTriangles(request.barrierTraiangles), 
                self.createTriangles(request.spaceTriangles)
                , request.zoom, request.crs, needs_closed_checking=False)
        
        return self.createGetSpatialIdsResponse(spatialIds)

    def FGetSpatialIdsOnPoints(self, request, context):
        print('GetSpatialIdsOnPoints')
        if request.crs == -1:
            spatialIds = point.f_get_spatial_ids_on_points(
                self.createPointList(request.points),
                request.zoom)
        else:
            spatialIds = point.f_get_spatial_ids_on_points(
                self.createPointList(request.points),
                request.zoom,
                request.crs)
            
        return self.createGetSpatialIdsResponse(spatialIds)
    
    def FGetVertexPointOnSpatialId(self, request, context):
        if request.crs == -1:
            points = point.f_get_point_on_spatial_id(
                request.spatialId, Point_Option.VERTEX)
        else:
            points = point.f_get_point_on_spatial_id(
                request.spatialId, Point_Option.VERTEX, crs)
        
        return self.createPointsResponse(points)
        
    def FGetCenterPointOnSpatialId(self, request, context):
        if request.crs == -1:
            points = f_get_point_on_spatial_id(
                request.spatialId, const.Point_Option.CENTER)
        else:
            points = f_get_point_on_spatial_id(
                request.spatialId, const.Point_Option.CENTER, crs)
             
        return self.createPointsResponse(points)

    def createTriangles(self, triangles):
        result = []
        result = [SpatialTriangle(self.createPoint(item.p1), self.createPoint(item.p2), self.createPoint(item.p3)) for item in triangles]
        
        #for item in triangles:
        #    result.append(SpatialTriangle(self.createPoint(item.p1), self.createPoint(item.p2), self.createPoint(item.p3)))
        return result

    # 座標リストを作成
    def createPointList(self, pointList):
        result = [self.createPoint(item) for item in pointList]
        
        #for item in pointList:
        #    result.append((self.createPoint(item)))
        return result

    def createPoint(self, point):
        return SpatialPoint(point.longitude, point.latitude, point.altitude)


    def createGetSpatialIdsResponse(self, ids):
        result = SpatialId_pb2.GetSpatialIdsResponse()
        for id in ids:
            result.ids.append(SpatialId_pb2.SpatialIdentification(ID=id))
        
        return result
        
    def createPointsResponse(self, points):
        result = SpatialId_pb2.PointsResponse()
        for point in points:
            if type(point) is SpatialPoint:
                result.point.append(SpatialId_pb2.Point(latitude=point.lat, longitude=point.lon, altitude=point.alt))
            elif type(point) is Projected_Point:
                result.point.append(SpatialId_pb2.Point(latitude=point.y, longitude=point.x, altitude=point.alt))
        return result

    def listTriangles(self, triangles):
        for item in triangles:
            print('p1:' + str(item.p1.latitude))

    # 円柱を複数つなげた経路が通る空間IDを取得
    def FGetSpatialIdsOnCylinders(self, request, context):
        print("-----FGetSpatialIdsOnCylinders start -------")
        spatialIds=cylinders.f_get_spatial_ids_on_cylinders(
        center=self.createPointList(request.pointList),
        radius=request.radius,
        zoom=request.zoom,
        crs=request.crs,
        is_capsule=request.is_capsule)
        print(spatialIds)

        return self.createGetSpatialIdsResponse(spatialIds)

    # 空間IDから空間中心座標の取得
    def FGetPointOnSpatialId(self, request, context):
        result = point.f_get_point_on_spatial_id(
            spatial_id=request.spatialId,
            option=Point_Option.CENTER
        )
        
        #ret = SpatialPoint(result[0].lon,result[0].lat,result[0].alt)
        #print(ret)
        result = SpatialId_pb2.Point(
            longitude=result[0].lon,
            latitude=result[0].lat,
            altitude=result[0].alt)
        print(result)
        return result





def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    SpatialId_pb2_grpc.add_SpatialIdServicer_to_server(
        SpatialIdServicer(), server)
    server.add_insecure_port('127.0.0.1:8980')
    server.start()
    print('server started');
    server.wait_for_termination()

if __name__ == '__main__':
    #logging.basicConfig(level=logging.INFO)
    SpatialLogger.MESSAGE_LEVEL = logging.INFO
    #SpatialLogger.MESSAGE_LEVEL = logging.DEBUG
    serve()

