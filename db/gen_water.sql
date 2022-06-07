drop table if exists gen_water;
drop sequence if exists gen_water_seq;
create sequence gen_water_seq;

create table gen_water as
  select nextval('gen_water_seq') AS id
        ,0 AS way_area
        ,10 AS res
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(way, 10)), 3)::geometry(MultiPolygon, 3857) as way
    from planet_osm_polygon
   where "natural" = 'water' or landuse = 'reservoir'
     and (water is null or water != 'riverbank');

delete from gen_water where st_area(st_buffer(way, -10)) < 10 and res = 10;

update gen_water set way = st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 10, 'quad_segs=1'), -10, 'quad_segs=1'), 10)) where res = 10;
update gen_water set way_area = st_area(way) where res = 10;

insert into gen_water
  select nextval('gen_water_seq') AS id,
         0,
         150,
         ST_CollectionExtract(unnest(ST_ClusterWithin(way, 100)), 3)::geometry(MultiPolygon, 3857)
    from gen_water
   where res = 10;

delete from gen_water where st_area(st_buffer(way, -50)) < 150 and res = 150;

update gen_water set way = st_multi(st_simplifypreservetopology(st_buffer(st_buffer(st_buffer(way, 50, 'quad_segs=1'), -100, 'quad_segs=1'), 50, 'quad_segs=1'), 100)) where res = 150;
update gen_water set way_area = st_area(way) where res = 150;

insert into gen_water
  select nextval('gen_water_seq') AS id,
         0,
         600,
         ST_CollectionExtract(unnest(ST_ClusterWithin(way, 295)), 3)::geometry(MultiPolygon, 3857)
    from gen_water
   where res = 150;

delete from gen_water where st_area(st_buffer(way, -295)) < 590 and res = 600;

update gen_water set way = st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 295, 'quad_segs=1'), -295, 'quad_segs=1'), 295)) where res = 600;
update gen_water set way_area = st_area(way) where res = 600;

create index gen_water_10_gix ON gen_water using gist (way) where res = 10;
create index gen_water_150_gix ON gen_water using gist (way) where res = 150;
create index gen_water_600_gix ON gen_water using gist (way) where res = 600;
