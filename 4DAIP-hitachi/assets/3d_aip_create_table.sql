/* 拡張機能 */
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_raster;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
--RDSでpostgis_sfcgalがサポート外のためコメントアウト
--CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;

/* QGISでGeometry型などを表示するための権限設定 */
ALTER ROLE postgres IN DATABASE "td_aip"
    SET search_path TO "td_aip", public;

/* D-1. 人口集中地区情報 */
CREATE TABLE IF NOT EXISTS td_aip.did_info
(
    data_id uuid NOT NULL,
    did_id integer,
    city_code character varying(5) COLLATE pg_catalog."default",
    city_name character varying(16) COLLATE pg_catalog."default",
    population integer,
    area double precision,
    census_year integer,
    did_geometry geometry(Geometry,6668) NOT NULL,
    create_time timestamp without time zone,
    update_time timestamp without time zone,
    CONSTRAINT did_info_pkey PRIMARY KEY (data_id)
);
CREATE INDEX IF NOT EXISTS did_info_did_geometry_idx
    ON td_aip.did_info USING gist(did_geometry);

/* D-2. 標高情報 */
CREATE TABLE IF NOT EXISTS td_aip.elevation_info
(
    data_id uuid NOT NULL,
    mesh_no integer,
    square geometry(Polygon,6668),
    elevation double precision,
    dem_file_name character varying COLLATE pg_catalog."default",
    cell_num_in_file integer,
    create_time timestamp without time zone,
    update_time timestamp without time zone,
    CONSTRAINT elevation_info_pkey PRIMARY KEY (data_id)
);
CREATE INDEX IF NOT EXISTS elevation_info_square_idx
    ON td_aip.elevation_info USING gist(square);

/* D-3. 風速実況 */
CREATE TABLE IF NOT EXISTS td_aip.wind_speed_live
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    cube geometry(GeometryZ,6697) NOT NULL,
    speed numeric(5,2) NOT NULL,
    forecast_period_start timestamp with time zone NOT NULL,
    forecast_period_end timestamp with time zone NOT NULL,
    CONSTRAINT wind_speed_live_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS wind_speed_live_cube_idx
    ON td_aip.wind_speed_live USING gist(cube gist_geometry_ops_nd);

/* D-4. 風速予報 */
CREATE TABLE IF NOT EXISTS td_aip.wind_speed_forecast
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    cube geometry(GeometryZ,6697) NOT NULL,
    speed numeric(5,2) NOT NULL,
    forecast_period_start timestamp with time zone NOT NULL,
    forecast_period_end timestamp with time zone NOT NULL,
    CONSTRAINT wind_speed_forecast_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS wind_speed_forecast_cube_idx
    ON td_aip.wind_speed_forecast USING gist(cube gist_geometry_ops_nd);

/* D-5. 有人機情報 */
CREATE TABLE IF NOT EXISTS td_aip.manned_aircraft_info
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    copilot_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
    location geometry(GeometryZ,6697) NOT NULL,
    direction smallint NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    speed numeric(6,2) NOT NULL,
    CONSTRAINT manned_aircraft_info_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS manned_aircraft_info_location_idx
    ON td_aip.manned_aircraft_info USING gist
    (location gist_geometry_ops_nd);

/* D-6. 3次元都市モデル情報 */
CREATE TABLE IF NOT EXISTS td_aip.plateau_data_info
(
    data_id uuid NOT NULL,
    feature_type integer NOT NULL,
    gml_id character varying(41) COLLATE pg_catalog."default" NOT NULL,
    bldg_id character varying(18) COLLATE pg_catalog."default",
    branch_no integer,
    height double precision,
    lod1 geometry(GeometryZ,6697) NOT NULL,
    create_time timestamp without time zone,
    update_time timestamp without time zone,
    CONSTRAINT plateau_data_info_pkey PRIMARY KEY (data_id)
);
CREATE INDEX IF NOT EXISTS plateau_data_info_lod1_idx
    ON td_aip.plateau_data_info USING gist(lod1 gist_geometry_ops_nd);
    
/* D-7. 降水量実況 */
CREATE TABLE IF NOT EXISTS td_aip.precipitation_live
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    square geometry(Geometry,6668) NOT NULL,
    intensity numeric(4,1) NOT NULL,
    forecast_period_start timestamp with time zone NOT NULL,
    forecast_period_end timestamp with time zone NOT NULL,
    CONSTRAINT precipitation_live_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS precipitation_live_square_idx
    ON td_aip.precipitation_live USING gist(square);

/* D-8. 降水量予報 */
CREATE TABLE IF NOT EXISTS td_aip.precipitation_forecast
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    square geometry(Geometry,6668) NOT NULL,
    intensity numeric(4,1) NOT NULL,
    forecast_period_start timestamp with time zone NOT NULL,
    forecast_period_end timestamp with time zone NOT NULL,
    CONSTRAINT precipitation_forecast_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS precipitation_forecast_square_idx
    ON td_aip.precipitation_forecast USING gist(square);

/* D-10. ジオイド高 */
CREATE SEQUENCE IF NOT EXISTS geoid_height_id_seq;
CREATE TABLE IF NOT EXISTS td_aip.geoid_height
(
    id integer NOT NULL DEFAULT nextval('geoid_height_id_seq'),
    raster raster NOT NULL,
    CONSTRAINT geoid_height_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS geoid_height_raster_idx
    ON td_aip.geoid_height USING gist(st_convexhull(raster));

/* D-11. 空間ID位置2D */
CREATE TABLE IF NOT EXISTS td_aip.spatial_id_location_2d
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    spatial_id_z integer NOT NULL,
    spatial_id_x integer NOT NULL,
    spatial_id_y integer NOT NULL,
    voxel geometry(Geometry,6668) NOT NULL,
    spatial_id text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT spatial_id_location_2d_pkey PRIMARY KEY (id),
    CONSTRAINT spatial_id_location_2d_unique UNIQUE (spatial_id_z, spatial_id_x, spatial_id_y)
);
CREATE UNIQUE INDEX IF NOT EXISTS spatial_id_location_2d_spatial_id_unique
    ON td_aip.spatial_id_location_2d USING btree(spatial_id COLLATE pg_catalog."default" ASC NULLS LAST);
CREATE INDEX IF NOT EXISTS spatial_id_location_2d_voxel_idx
    ON td_aip.spatial_id_location_2d USING gist(voxel);
CREATE INDEX IF NOT EXISTS spatial_id_location_2d_voxel_trans_6677_idx
    ON td_aip.spatial_id_location_2d USING gist(st_transform(voxel, 6677));

/* D-12 空間ID位置3D */
CREATE TABLE IF NOT EXISTS td_aip.spatial_id_location_3d
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    spatial_id_z integer NOT NULL,
    spatial_id_f integer NOT NULL,
    spatial_id_x integer NOT NULL,
    spatial_id_y integer NOT NULL,
    voxel geometry(GeometryZ,6697) NOT NULL,
    spatial_id text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT spatial_id_location_3d_pkey PRIMARY KEY (id),
    CONSTRAINT spatial_id_location_3d_unique UNIQUE (spatial_id_z, spatial_id_f, spatial_id_x, spatial_id_y)
);
CREATE UNIQUE INDEX IF NOT EXISTS spatial_id_location_3d_spatial_id_unique
    ON td_aip.spatial_id_location_3d USING btree(spatial_id COLLATE pg_catalog."default" ASC NULLS LAST);
CREATE INDEX IF NOT EXISTS spatial_id_location_3d_voxel_idx
    ON td_aip.spatial_id_location_3d USING gist(voxel gist_geometry_ops_nd);
CREATE INDEX IF NOT EXISTS spatial_id_location_3d_voxel_trans_6677_idx
    ON td_aip.spatial_id_location_3d USING gist(st_transform(voxel, 6677) gist_geometry_ops_nd);

/* D-13 ユーザ情報 */
CREATE TABLE IF NOT EXISTS td_aip.user_info
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id text COLLATE pg_catalog."default" NOT NULL,
    password text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT user_info_pkey PRIMARY KEY (id),
    CONSTRAINT user_info_unique UNIQUE (user_id)
);
INSERT INTO td_aip.user_info (user_id, password) VALUES
('ut01', crypt('tdaip', gen_salt('bf', 6))),
('ut02', crypt('tdaip', gen_salt('bf', 6))),
('ut03', crypt('tdaip', gen_salt('bf', 6))),
('ut04', crypt('tdaip', gen_salt('bf', 6))),
('ut05', crypt('tdaip', gen_salt('bf', 6)));

/* D-14 ユーザ-認可 */
CREATE TABLE IF NOT EXISTS td_aip.user_authorization
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_info_id uuid NOT NULL,
    authorization_info_id uuid NOT NULL,
    CONSTRAINT user_authorization_pkey PRIMARY KEY (id),
    CONSTRAINT user_authorization_unique UNIQUE (user_info_id, authorization_info_id)
);

/* D-15 認可情報 */
CREATE TABLE IF NOT EXISTS td_aip.authorization_info
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    path text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT authorization_info_pkey PRIMARY KEY (id),
    CONSTRAINT authorization_info_unique UNIQUE (path)
);
INSERT INTO td_aip.authorization_info(path) VALUES 
('/common_service/loc_put_airspace'),
('/common_service/loc_put_reserve_area'),
('/common_service/loc_select_airspace'),
('/common_service/loc_delete'),
('/common_service/loc_get_value'),
('/common_service/loc_select_airspace_arrangement'),
('/common_service/loc_select_airspace_arrangement_stream');

-- ut01
INSERT INTO td_aip.user_authorization(user_info_id, authorization_info_id) 
SELECT
  u.id,
  a.id
FROM td_aip.user_info u,
  td_aip.authorization_info a
WHERE u.user_id = 'ut01';
-- ut02
INSERT INTO td_aip.user_authorization(user_info_id, authorization_info_id) 
SELECT
  u.id,
  a.id
FROM td_aip.user_info u,
  td_aip.authorization_info a
WHERE u.user_id = 'ut02'
  AND a.path IN(
    '/common_service/loc_get_value',
    '/common_service/loc_select_airspace_arrangement',
    '/common_service/loc_select_airspace_arrangement_stream'
  );
-- ut03
INSERT INTO td_aip.user_authorization(user_info_id, authorization_info_id) 
SELECT
  u.id,
  a.id
FROM td_aip.user_info u,
  td_aip.authorization_info a
WHERE u.user_id = 'ut03'
  AND a.path NOT IN(
    '/common_service/loc_put_reserve_area'
  );
-- ut04
INSERT INTO td_aip.user_authorization(user_info_id, authorization_info_id) 
SELECT
  u.id,
  a.id
FROM td_aip.user_info u,
  td_aip.authorization_info a
WHERE u.user_id = 'ut04'
  AND a.path NOT IN(
    '/common_service/loc_put_airspace'
  );

/* D-16 ドローン領域APIにより登録する空域 */
CREATE SEQUENCE IF NOT EXISTS drone_domain_api_airspace_object_id_seq;
CREATE TABLE IF NOT EXISTS td_aip.drone_domain_api_airspace
(
    object_id bigint NOT NULL DEFAULT nextval('drone_domain_api_airspace_object_id_seq'::regclass),
    user_info_id uuid NOT NULL,
    attr text COLLATE pg_catalog."default" NOT NULL,
    reference text COLLATE pg_catalog."default" NOT NULL,
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    CONSTRAINT drone_domain_api_airspace_pkey PRIMARY KEY (object_id)
);
CREATE INDEX IF NOT EXISTS drone_domain_api_airspace_idx
    ON td_aip.drone_domain_api_airspace USING btree
    (attr COLLATE pg_catalog."default" ASC NULLS LAST, object_id ASC NULLS LAST, user_info_id ASC NULLS LAST);

/* D-17 ドローン領域APIにより登録する空域の空間ID */
CREATE TABLE IF NOT EXISTS td_aip.drone_domain_api_airspace_spatial_id
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    object_id bigint NOT NULL,
    spatial_id_z integer NOT NULL,
    spatial_id_f integer NOT NULL,
    spatial_id_x integer NOT NULL,
    spatial_id_y integer NOT NULL,
    period_start timestamp with time zone NOT NULL DEFAULT '-infinity'::timestamp without time zone,
    period_end timestamp with time zone NOT NULL DEFAULT 'infinity'::timestamp without time zone,
    create_time timestamp with time zone NOT NULL,
    CONSTRAINT drone_domain_api_airspace_spatial_id_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS drone_domain_api_airspace_spatial_id_idx
    ON td_aip.drone_domain_api_airspace_spatial_id USING btree
    (spatial_id_z ASC NULLS LAST, spatial_id_f ASC NULLS LAST, spatial_id_x ASC NULLS LAST, spatial_id_y ASC NULLS LAST, period_start ASC NULLS LAST, period_end ASC NULLS LAST, object_id ASC NULLS LAST);

/* D-18 飛行可能空域Streamで変化を取得のリクエスト */
CREATE TABLE IF NOT EXISTS td_aip.flyable_airspace_stream_alteration_request
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    period_start timestamp with time zone NOT NULL,
    period_end timestamp with time zone NOT NULL,
    create_time timestamp with time zone NOT NULL,
    CONSTRAINT flyable_airspace_stream_alteration_request_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS flyable_airspace_stream_alteration_request_idx
    ON td_aip.flyable_airspace_stream_alteration_request USING btree
    (id ASC NULLS LAST, period_start ASC NULLS LAST, period_end ASC NULLS LAST);

/* D-19 飛行可能空域Streamで変化を取得のリクエストの空間ID */
CREATE TABLE IF NOT EXISTS td_aip.flyable_airspace_stream_alteration_request_spatial_id
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    flyable_airspace_stream_alteration_request_id uuid NOT NULL,
    spatial_id_z integer NOT NULL,
    spatial_id_f integer NOT NULL,
    spatial_id_x integer NOT NULL,
    spatial_id_y integer NOT NULL,
    CONSTRAINT flyable_airspace_stream_alteration_request_spatial_id_pkey PRIMARY KEY (id),
    CONSTRAINT flyable_airspace_stream_alteration_request_spatial_id_unique UNIQUE (flyable_airspace_stream_alteration_request_id, spatial_id_z, spatial_id_f, spatial_id_x, spatial_id_y)
);

/* D-20 飛行可能空域Streamで変化を取得のリクエストの無視する登録ID */
CREATE TABLE IF NOT EXISTS td_aip.flyable_airspace_stream_alteration_request_ignore_object_id
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    flyable_airspace_stream_alteration_request_id uuid NOT NULL,
    ignore_object_id bigint NOT NULL,
    CONSTRAINT flyable_airspace_stream_alteration_request_ignore_object_id_pke PRIMARY KEY (id),
    CONSTRAINT flyable_airspace_stream_alteration_request_ignore_object_id_uni UNIQUE (flyable_airspace_stream_alteration_request_id, ignore_object_id)
);

/* D-21. DIPS飛行計画情報 */
CREATE TABLE IF NOT EXISTS td_aip.dips_flight_plan_info
(
    data_id uuid NOT NULL DEFAULT gen_random_uuid(),
    dips_flight_plan_id character varying COLLATE pg_catalog."default" NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    planned_max_time integer,
    planned_flight_time integer,
    flight_speed numeric,
    flight_altitude numeric,
    fly_route geometry(Geometry,6668) NOT NULL,
    CONSTRAINT dips_flight_plan_info_pkey PRIMARY KEY (data_id),
    CONSTRAINT dips_flight_plan_id_unique UNIQUE (dips_flight_plan_id)
);
CREATE INDEX IF NOT EXISTS dips_flight_plan_info_fly_route_idx
    ON td_aip.dips_flight_plan_info USING gist(fly_route);

/* D-22. DIPS飛行禁止エリア情報 */
CREATE TABLE IF NOT EXISTS td_aip.dips_no_fly_area_info
(
    data_id uuid NOT NULL DEFAULT gen_random_uuid(),
    dips_flight_prohibited_area_id character varying COLLATE pg_catalog."default" NOT NULL,
    name character varying COLLATE pg_catalog."default",
    detail character varying COLLATE pg_catalog."default",
    url character varying COLLATE pg_catalog."default",
    flight_prohibited_area_type_id integer,
    start_time timestamp with time zone NOT NULL,
    finish_time timestamp with time zone NOT NULL,
    area geometry(Geometry,6668) NOT NULL,
    CONSTRAINT dips_no_fly_area_info_pkey PRIMARY KEY (data_id),
    CONSTRAINT dips_flight_prohibited_area_id_unique UNIQUE (dips_flight_prohibited_area_id)
);
CREATE INDEX IF NOT EXISTS dips_no_fly_area_info_area_idx
    ON td_aip.dips_no_fly_area_info USING gist(area);

/* D-9. 空間ボクセル情報 */
CREATE TABLE IF NOT EXISTS td_aip.voxel_info
(
  uid uuid NOT NULL,
  spatial_id_z integer NOT NULL,
  spatial_id_f integer,
  spatial_id_x integer NOT NULL,
  spatial_id_y integer NOT NULL,
  data_type integer NOT NULL,
  data_id uuid,
  data_value jsonb,
  buffer_flg boolean,
  buffer_distance double precision,
  ground_risk_calc_condition integer,
  air_risk_calc_condition integer,
  validity_start_time timestamp without time zone NOT NULL,
  validity_end_time timestamp without time zone NOT NULL,
  create_time timestamp without time zone,
  update_time timestamp without time zone
)PARTITION BY LIST (data_type);

CREATE INDEX IF NOT EXISTS vi_data_value_idx
  ON td_aip.voxel_info USING gin(data_value jsonb_path_ops);

CREATE INDEX IF NOT EXISTS vi_spatial_id_z_f_x_y_idx
  ON td_aip.voxel_info USING btree(
    spatial_id_z ASC NULLS LAST,
    spatial_id_f ASC NULLS LAST,
    spatial_id_x ASC NULLS LAST,
    spatial_id_y ASC NULLS LAST);

--ここから2階層目
-- 人口集中地区：16843008
CREATE TABLE IF NOT EXISTS td_aip.vi_did
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_did_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (16843008);

-- 標高情報：16843265, 16843266
CREATE TABLE IF NOT EXISTS td_aip.vi_elevation
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_elevation_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (16843265, 16843266);

-- ３次元都市モデル：16843777, 16843778, 16843780
CREATE TABLE IF NOT EXISTS td_aip.vi_plateau
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_plateau_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (16843777, 16843778, 16843780);

-- 風速実況：16908545
CREATE TABLE IF NOT EXISTS td_aip.vi_wind_speed_live
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_wind_speed_live_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (16908545);

-- 風速予測：16908546
CREATE TABLE IF NOT EXISTS td_aip.vi_wind_speed_forecast
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_wind_speed_forecast_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (16908546);

-- 降水量実況：16908801
CREATE TABLE IF NOT EXISTS td_aip.vi_precipitation_live
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_precipitation_live_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (16908801);

-- 降水量予測：16908802
CREATE TABLE IF NOT EXISTS td_aip.vi_precipitation_forecast
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_precipitation_forecast_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (16908802);

-- 有人機情報：17039360
CREATE TABLE IF NOT EXISTS td_aip.vi_manned_aircraft
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_manned_aircraft_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (17039360);

-- 飛行計画：17301760
CREATE TABLE IF NOT EXISTS td_aip.vi_dips_flight_plan
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_dips_flight_plan_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (17301760);

-- 飛行禁止エリア：17302016
CREATE TABLE IF NOT EXISTS td_aip.vi_dips_no_fly_area
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_dips_no_fly_area_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (17302016);

-- リスク算出結果_地上：33619968
CREATE TABLE IF NOT EXISTS td_aip.vi_risk_calc_result_ground
  PARTITION OF td_aip.voxel_info
  FOR VALUES IN (33619968)
  PARTITION BY RANGE (spatial_id_f);

-- リスク算出結果_上空：33685504
CREATE TABLE IF NOT EXISTS td_aip.vi_risk_calc_result_air_space
  PARTITION OF td_aip.voxel_info
  FOR VALUES IN (33685504)
  PARTITION BY RANGE (spatial_id_f);

-- リスク算出結果_予測：33816576
CREATE TABLE IF NOT EXISTS td_aip.vi_risk_calc_result_predicted
  PARTITION OF td_aip.voxel_info
  FOR VALUES IN (33816576)
  PARTITION BY RANGE (spatial_id_f);

-- リスク緩和後_地上：67174400
CREATE TABLE IF NOT EXISTS td_aip.vi_risk_calc_adjusted_ground
  PARTITION OF td_aip.voxel_info
  FOR VALUES IN (67174400)
  PARTITION BY RANGE (spatial_id_f);

-- リスク緩和後_上空：67239936
CREATE TABLE IF NOT EXISTS td_aip.vi_risk_calc_adjusted_air_space
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_risk_calc_adjusted_air_space_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (67239936);

-- リスク緩和後_予測：67371008
CREATE TABLE IF NOT EXISTS td_aip.vi_risk_calc_adjusted_predicted
  PARTITION OF td_aip.voxel_info(
    CONSTRAINT vi_risk_calc_adjusted_predicted_pk PRIMARY KEY (uid)
  )
  FOR VALUES IN (67371008);
  
-- ここから3階層目
-- リスク算出結果_地上_F-1
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_-1"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_-1_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (-1) TO (0);

-- リスク算出結果_地上_F0
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_0"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_0_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (0) TO (1);

-- リスク算出結果_地上_F1
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_1"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_1_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (1) TO (2);

-- リスク算出結果_地上_F2
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_2"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_2_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (2) TO (3);

-- リスク算出結果_地上_F3
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_3"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_3_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (3) TO (4);

-- リスク算出結果_地上_F4
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_4"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_4_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (4) TO (5);

-- リスク算出結果_地上_F5
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_5"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_5_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (5) TO (6);

-- リスク算出結果_地上_F6
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_6"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_6_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (6) TO (7);

-- リスク算出結果_地上_F7
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_7"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_7_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (7) TO (8);

-- リスク算出結果_地上_F8
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_8"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_8_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (8) TO (9);

-- リスク算出結果_地上_F9
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_9"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_9_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (9) TO (10);

-- リスク算出結果_地上_F10
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_10"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_10_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (10) TO (11);

-- リスク算出結果_地上_F11
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_11"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_11_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (11) TO (12);

-- リスク算出結果_地上_F12
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_12"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_12_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (12) TO (13);

-- リスク算出結果_地上_F13
CREATE TABLE IF NOT EXISTS td_aip."vi_r_g_f_13"
  PARTITION OF td_aip.vi_risk_calc_result_ground(
    CONSTRAINT "vi_r_g_f_13_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (13) TO (14);

-- リスク算出結果_上空_F-1
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_-1"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (-1) TO (0)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F0
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_0"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (0) TO (1)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F1
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_1"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (1) TO (2)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F2
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_2"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (2) TO (3)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F3
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_3"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (3) TO (4)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F4
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_4"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (4) TO (5)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F5
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_5"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (5) TO (6)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F6
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_6"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (6) TO (7)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F7
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_7"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (7) TO (8)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F8
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_8"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (8) TO (9)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F9
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_9"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (9) TO (10)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F10
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_10"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (10) TO (11)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F11
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_11"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (11) TO (12)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F12
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_12"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (12) TO (13)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_上空_F13
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_13"
  PARTITION OF td_aip.vi_risk_calc_result_air_space
  FOR VALUES FROM (13) TO (14)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F-1
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_-1"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (-1) TO (0)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F0
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_0"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (0) TO (1)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F1
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_1"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (1) TO (2)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F2
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_2"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (2) TO (3)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F3
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_3"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (3) TO (4)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F4
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_4"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (4) TO (5)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F5
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_5"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (5) TO (6)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F6
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_6"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (6) TO (7)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F7
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_7"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (7) TO (8)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F8
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_8"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (8) TO (9)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F9
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_9"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (9) TO (10)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F10
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_10"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (10) TO (11)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F11
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_11"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (11) TO (12)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F12
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_12"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (12) TO (13)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク算出結果_予測_F13
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_13"
  PARTITION OF td_aip.vi_risk_calc_result_predicted
  FOR VALUES FROM (13) TO (14)
  PARTITION BY LIST (air_risk_calc_condition);

-- リスク緩和後_地上_F-1
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_-1"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_-1_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (-1) TO (0);

-- リスク緩和後_地上_F0
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_0"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_0_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (0) TO (1);

-- リスク緩和後_地上_F1
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_1"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_1_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (1) TO (2);

-- リスク緩和後_地上_F2
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_2"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_2_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (2) TO (3);

-- リスク緩和後_地上_F3
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_3"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_3_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (3) TO (4);

-- リスク緩和後_地上_F4
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_4"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_4_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (4) TO (5);

-- リスク緩和後_地上_F5
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_5"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_5_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (5) TO (6);

-- リスク緩和後_地上_F6
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_6"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_6_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (6) TO (7);

-- リスク緩和後_地上_F7
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_7"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_7_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (7) TO (8);

-- リスク緩和後_地上_F8
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_8"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_8_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (8) TO (9);

-- リスク緩和後_地上_F9
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_9"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_9_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (9) TO (10);

-- リスク緩和後_地上_F10
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_10"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_10_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (10) TO (11);

-- リスク緩和後_地上_F11
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_11"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_11_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (11) TO (12);

-- リスク緩和後_地上_F12
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_12"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_12_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (12) TO (13);

-- リスク緩和後_地上_F13
CREATE TABLE IF NOT EXISTS td_aip."vi_a_g_f_13"
  PARTITION OF td_aip.vi_risk_calc_adjusted_ground(
    CONSTRAINT "vi_a_g_f_13_pk" PRIMARY KEY (uid)
  )
  FOR VALUES FROM (13) TO (14);

-- ここから4階層目
-- リスク算出結果_上空_F-1_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_-1_precipitation"
  PARTITION OF td_aip."vi_r_a_f_-1"(
    CONSTRAINT "vi_r_a_f_-1_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F0未満_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_-1_wind"
  PARTITION OF td_aip."vi_r_a_f_-1"(
    CONSTRAINT "vi_r_a_f_-1_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F0未満_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_-1_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_-1"(
    CONSTRAINT "vi_r_a_f_-1_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F0未満_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_-1_other"
  PARTITION OF td_aip."vi_r_a_f_-1"(
    CONSTRAINT "vi_r_a_f_-1_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F0_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_0_precipitation"
  PARTITION OF td_aip."vi_r_a_f_0"(
    CONSTRAINT "vi_r_a_f_0_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F0_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_0_wind"
  PARTITION OF td_aip."vi_r_a_f_0"(
    CONSTRAINT "vi_r_a_f_0_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F0_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_0_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_0"(
    CONSTRAINT "vi_r_a_f_0_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F0_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_0_other"
  PARTITION OF td_aip."vi_r_a_f_0"(
    CONSTRAINT "vi_r_a_f_0_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F1_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_1_precipitation"
  PARTITION OF td_aip."vi_r_a_f_1"(
    CONSTRAINT "vi_r_a_f_1_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F1_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_1_wind"
  PARTITION OF td_aip."vi_r_a_f_1"(
    CONSTRAINT "vi_r_a_f_1_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F1_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_1_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_1"(
    CONSTRAINT "vi_r_a_f_1_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F1_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_1_other"
  PARTITION OF td_aip."vi_r_a_f_1"(
    CONSTRAINT "vi_r_a_f_1_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F2_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_2_precipitation"
  PARTITION OF td_aip."vi_r_a_f_2"(
    CONSTRAINT "vi_r_a_f_2_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F2_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_2_wind"
  PARTITION OF td_aip."vi_r_a_f_2"(
    CONSTRAINT "vi_r_a_f_2_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F2_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_2_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_2"(
    CONSTRAINT "vi_r_a_f_2_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F2_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_2_other"
  PARTITION OF td_aip."vi_r_a_f_2"(
    CONSTRAINT "vi_r_a_f_2_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F3_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_3_precipitation"
  PARTITION OF td_aip."vi_r_a_f_3"(
    CONSTRAINT "vi_r_a_f_3_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F3_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_3_wind"
  PARTITION OF td_aip."vi_r_a_f_3"(
    CONSTRAINT "vi_r_a_f_3_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F3_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_3_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_3"(
    CONSTRAINT "vi_r_a_f_3_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F3_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_3_other"
  PARTITION OF td_aip."vi_r_a_f_3"(
    CONSTRAINT "vi_r_a_f_3_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F4_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_4_precipitation"
  PARTITION OF td_aip."vi_r_a_f_4"(
    CONSTRAINT "vi_r_a_f_4_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F4_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_4_wind"
  PARTITION OF td_aip."vi_r_a_f_4"(
    CONSTRAINT "vi_r_a_f_4_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F4_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_4_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_4"(
    CONSTRAINT "vi_r_a_f_4_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F4_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_4_other"
  PARTITION OF td_aip."vi_r_a_f_4"(
    CONSTRAINT "vi_r_a_f_4_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F5_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_5_precipitation"
  PARTITION OF td_aip."vi_r_a_f_5"(
    CONSTRAINT "vi_r_a_f_5_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F5_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_5_wind"
  PARTITION OF td_aip."vi_r_a_f_5"(
    CONSTRAINT "vi_r_a_f_5_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F5_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_5_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_5"(
    CONSTRAINT "vi_r_a_f_5_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F5_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_5_other"
  PARTITION OF td_aip."vi_r_a_f_5"(
    CONSTRAINT "vi_r_a_f_5_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F6_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_6_precipitation"
  PARTITION OF td_aip."vi_r_a_f_6"(
    CONSTRAINT "vi_r_a_f_6_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F6_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_6_wind"
  PARTITION OF td_aip."vi_r_a_f_6"(
    CONSTRAINT "vi_r_a_f_6_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F6_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_6_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_6"(
    CONSTRAINT "vi_r_a_f_6_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F6_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_6_other"
  PARTITION OF td_aip."vi_r_a_f_6"(
    CONSTRAINT "vi_r_a_f_6_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F7_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_7_precipitation"
  PARTITION OF td_aip."vi_r_a_f_7"(
    CONSTRAINT "vi_r_a_f_7_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F7_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_7_wind"
  PARTITION OF td_aip."vi_r_a_f_7"(
    CONSTRAINT "vi_r_a_f_7_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F7_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_7_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_7"(
    CONSTRAINT "vi_r_a_f_7_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F7_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_7_other"
  PARTITION OF td_aip."vi_r_a_f_7"(
    CONSTRAINT "vi_r_a_f_7_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F8_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_8_precipitation"
  PARTITION OF td_aip."vi_r_a_f_8"(
    CONSTRAINT "vi_r_a_f_8_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F8_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_8_wind"
  PARTITION OF td_aip."vi_r_a_f_8"(
    CONSTRAINT "vi_r_a_f_8_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F8_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_8_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_8"(
    CONSTRAINT "vi_r_a_f_8_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F8_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_8_other"
  PARTITION OF td_aip."vi_r_a_f_8"(
    CONSTRAINT "vi_r_a_f_8_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F9_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_9_precipitation"
  PARTITION OF td_aip."vi_r_a_f_9"(
    CONSTRAINT "vi_r_a_f_9_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F9_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_9_wind"
  PARTITION OF td_aip."vi_r_a_f_9"(
    CONSTRAINT "vi_r_a_f_9_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F9_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_9_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_9"(
    CONSTRAINT "vi_r_a_f_9_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F9_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_9_other"
  PARTITION OF td_aip."vi_r_a_f_9"(
    CONSTRAINT "vi_r_a_f_9_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F10_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_10_precipitation"
  PARTITION OF td_aip."vi_r_a_f_10"(
    CONSTRAINT "vi_r_a_f_10_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F10_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_10_wind"
  PARTITION OF td_aip."vi_r_a_f_10"(
    CONSTRAINT "vi_r_a_f_10_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F10_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_10_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_10"(
    CONSTRAINT "vi_r_a_f_10_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F10_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_10_other"
  PARTITION OF td_aip."vi_r_a_f_10"(
    CONSTRAINT "vi_r_a_f_10_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F11_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_11_precipitation"
  PARTITION OF td_aip."vi_r_a_f_11"(
    CONSTRAINT "vi_r_a_f_11_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F11_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_11_wind"
  PARTITION OF td_aip."vi_r_a_f_11"(
    CONSTRAINT "vi_r_a_f_11_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F11_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_11_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_11"(
    CONSTRAINT "vi_r_a_f_11_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F11_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_11_other"
  PARTITION OF td_aip."vi_r_a_f_11"(
    CONSTRAINT "vi_r_a_f_11_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F12_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_12_precipitation"
  PARTITION OF td_aip."vi_r_a_f_12"(
    CONSTRAINT "vi_r_a_f_12_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F12_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_12_wind"
  PARTITION OF td_aip."vi_r_a_f_12"(
    CONSTRAINT "vi_r_a_f_12_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F12_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_12_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_12"(
    CONSTRAINT "vi_r_a_f_12_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F12_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_12_other"
  PARTITION OF td_aip."vi_r_a_f_12"(
    CONSTRAINT "vi_r_a_f_12_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_上空_F13_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_13_precipitation"
  PARTITION OF td_aip."vi_r_a_f_13"(
    CONSTRAINT "vi_r_a_f_13_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_上空_F13_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_13_wind"
  PARTITION OF td_aip."vi_r_a_f_13"(
    CONSTRAINT "vi_r_a_f_13_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_上空_F13_有人機接近
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_13_manned_aircraft"
  PARTITION OF td_aip."vi_r_a_f_13"(
    CONSTRAINT "vi_r_a_f_13_manned_aircraft_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (10);

-- リスク算出結果_上空_F13_その他
CREATE TABLE IF NOT EXISTS td_aip."vi_r_a_f_13_other"
  PARTITION OF td_aip."vi_r_a_f_13"(
    CONSTRAINT "vi_r_a_f_13_other_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (1,2,3,5,6,9,11,12,13,14,15);

-- リスク算出結果_予測_F-1_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_-1_precipitation"
  PARTITION OF td_aip."vi_r_p_f_-1"(
    CONSTRAINT "vi_r_p_f_-1_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F-1_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_-1_wind"
  PARTITION OF td_aip."vi_r_p_f_-1"(
    CONSTRAINT "vi_r_p_f_-1_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F0_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_0_precipitation"
  PARTITION OF td_aip."vi_r_p_f_0"(
    CONSTRAINT "vi_r_p_f_0_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F0_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_0_wind"
  PARTITION OF td_aip."vi_r_p_f_0"(
    CONSTRAINT "vi_r_p_f_0_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F1_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_1_precipitation"
  PARTITION OF td_aip."vi_r_p_f_1"(
    CONSTRAINT "vi_r_p_f_1_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F1_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_1_wind"
  PARTITION OF td_aip."vi_r_p_f_1"(
    CONSTRAINT "vi_r_p_f_1_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F2_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_2_precipitation"
  PARTITION OF td_aip."vi_r_p_f_2"(
    CONSTRAINT "vi_r_p_f_2_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F2_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_2_wind"
  PARTITION OF td_aip."vi_r_p_f_2"(
    CONSTRAINT "vi_r_p_f_2_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F3_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_3_precipitation"
  PARTITION OF td_aip."vi_r_p_f_3"(
    CONSTRAINT "vi_r_p_f_3_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F3_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_3_wind"
  PARTITION OF td_aip."vi_r_p_f_3"(
    CONSTRAINT "vi_r_p_f_3_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F4_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_4_precipitation"
  PARTITION OF td_aip."vi_r_p_f_4"(
    CONSTRAINT "vi_r_p_f_4_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F4_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_4_wind"
  PARTITION OF td_aip."vi_r_p_f_4"(
    CONSTRAINT "vi_r_p_f_4_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F5_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_5_precipitation"
  PARTITION OF td_aip."vi_r_p_f_5"(
    CONSTRAINT "vi_r_p_f_5_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F5_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_5_wind"
  PARTITION OF td_aip."vi_r_p_f_5"(
    CONSTRAINT "vi_r_p_f_5_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F6_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_6_precipitation"
  PARTITION OF td_aip."vi_r_p_f_6"(
    CONSTRAINT "vi_r_p_f_6_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F6_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_6_wind"
  PARTITION OF td_aip."vi_r_p_f_6"(
    CONSTRAINT "vi_r_p_f_6_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F7_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_7_precipitation"
  PARTITION OF td_aip."vi_r_p_f_7"(
    CONSTRAINT "vi_r_p_f_7_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F7_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_7_wind"
  PARTITION OF td_aip."vi_r_p_f_7"(
    CONSTRAINT "vi_r_p_f_7_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F8_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_8_precipitation"
  PARTITION OF td_aip."vi_r_p_f_8"(
    CONSTRAINT "vi_r_p_f_8_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F8_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_8_wind"
  PARTITION OF td_aip."vi_r_p_f_8"(
    CONSTRAINT "vi_r_p_f_8_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F9_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_9_precipitation"
  PARTITION OF td_aip."vi_r_p_f_9"(
    CONSTRAINT "vi_r_p_f_9_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F9_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_9_wind"
  PARTITION OF td_aip."vi_r_p_f_9"(
    CONSTRAINT "vi_r_p_f_9_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F10_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_10_precipitation"
  PARTITION OF td_aip."vi_r_p_f_10"(
    CONSTRAINT "vi_r_p_f_10_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F10_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_10_wind"
  PARTITION OF td_aip."vi_r_p_f_10"(
    CONSTRAINT "vi_r_p_f_10_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F11_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_11_precipitation"
  PARTITION OF td_aip."vi_r_p_f_11"(
    CONSTRAINT "vi_r_p_f_11_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F11_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_11_wind"
  PARTITION OF td_aip."vi_r_p_f_11"(
    CONSTRAINT "vi_r_p_f_11_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F12_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_12_precipitation"
  PARTITION OF td_aip."vi_r_p_f_12"(
    CONSTRAINT "vi_r_p_f_12_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F12_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_12_wind"
  PARTITION OF td_aip."vi_r_p_f_12"(
    CONSTRAINT "vi_r_p_f_12_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

-- リスク算出結果_予測_F13_降水量
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_13_precipitation"
  PARTITION OF td_aip."vi_r_p_f_13"(
    CONSTRAINT "vi_r_p_f_13_precipitation_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (4,7);

-- リスク算出結果_予測_F13_風速
CREATE TABLE IF NOT EXISTS td_aip."vi_r_p_f_13_wind"
  PARTITION OF td_aip."vi_r_p_f_13"(
    CONSTRAINT "vi_r_p_f_13_wind_pk" PRIMARY KEY (uid)
  )
  FOR VALUES IN (8);

/* Viewerの2D用のビュー 
CREATE OR REPLACE VIEW td_aip.v_voxel_info_location_2d AS
SELECT s.id,
    v.uid,
    v.spatial_id_z,
    v.spatial_id_x,
    v.spatial_id_y,
    v.data_type,
    v.data_id,
    v.data_value,
    v.buffer_flg,
    v.buffer_distance,
    v.ground_risk_calc_condition,
    v.air_risk_calc_condition,
    v.validity_start_time,
    v.validity_end_time,
    v.create_time,
    v.update_time,
    s.voxel
FROM td_aip.voxel_info v
    INNER JOIN td_aip.spatial_id_location_2d s
      ON v.spatial_id_z = s.spatial_id_z
      AND v.spatial_id_f IS NULL 
      AND v.spatial_id_x = s.spatial_id_x
      AND v.spatial_id_y = s.spatial_id_y;
*/

/* Viewerの3D用のビュー 


CREATE OR REPLACE VIEW td_aip.v_voxel_info_location_3d AS
SELECT s.id,
    v.uid,
    v.spatial_id_z,
    v.spatial_id_f,
    v.spatial_id_x,
    v.spatial_id_y,
    v.data_type,
    v.data_id,
    v.data_value,
    v.buffer_flg,
    v.buffer_distance,
    v.ground_risk_calc_condition,
    v.air_risk_calc_condition,
    v.validity_start_time,
    v.validity_end_time,
    v.create_time,
    v.update_time,
    s.voxel
FROM td_aip.voxel_info v
  INNER JOIN td_aip.spatial_id_location_3d s 
    ON v.spatial_id_z = s.spatial_id_z 
    AND v.spatial_id_f = s.spatial_id_f 
    AND v.spatial_id_x = s.spatial_id_x 
    AND v.spatial_id_y = s.spatial_id_y;
*/