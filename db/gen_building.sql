drop table if exists gen_building;
create table gen_building as
  select 0 AS way_area
        ,10 AS res
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(way, 10)), 3)::geometry(MultiPolygon, 3857) as way
    from planet_osm_polygon
   where building is not null;

delete from gen_building where st_area(st_buffer(way, -6)) < 6 and res = 10;

update gen_building set way = st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 30, 'join=mitre'), -30, 'join=mitre'), 1)) where res = 10;
update gen_building set way = st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, -5, 'join=mitre'),   5, 'join=mitre'), 1)) where res = 10;
update gen_building set way_area = st_area(way) where res = 10;

create index gen_building_gix ON gen_building using gist (way);
