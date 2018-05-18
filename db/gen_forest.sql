drop table if exists gen_forest;
drop sequence if exists gen_forest_seq;
create sequence gen_forest_seq;

------------------
-- resolution 10
------------------
create table gen_forest as
  select nextval('gen_forest_seq') AS id
        ,0::bigint AS way_area
        ,10 AS res
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(way, 10)), 3)::geometry(MultiPolygon, 3857) as way
    from planet_osm_polygon
   where landuse = 'forest';

delete from gen_forest where st_area(st_buffer(way, -10)) < 10 and res = 10;

update gen_forest set way = st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 10, 'quad_segs=1'), -10, 'quad_segs=1'), 10))) where res = 10;
update gen_forest set way_area = st_area(way) where res = 10;

-------------------
-- resolution 150
-------------------
insert into gen_forest
  select nextval('gen_forest_seq') AS id,
         0,
         150,
         ST_CollectionExtract(unnest(ST_ClusterWithin(way, 150)), 3)::geometry(MultiPolygon, 3857)
    from gen_forest
   where res = 10;

delete from gen_forest where st_area(st_buffer(way, -150)) < 150 and res = 150;

update gen_forest set way = st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 150, 'quad_segs=1'), -150, 'quad_segs=1'), 150))) where res = 150;
update gen_forest set way_area = st_area(way) where res = 150;

-------------------
-- resolution 600
-------------------
insert into gen_forest
  select nextval('gen_forest_seq') AS id,
         0,
         600,
         ST_CollectionExtract(unnest(ST_ClusterWithin(way, 300)), 3)::geometry(MultiPolygon, 3857)
    from gen_forest
   where res = 150;

delete from gen_forest where st_area(st_buffer(way, -600)) < 600 and res = 600;

update gen_forest set way = st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 1200, 'quad_segs=1'), -1200, 'quad_segs=1'), 600))) where res = 600;
update gen_forest set way_area = st_area(way) where res = 600;

create index gen_forest_10_gix ON gen_forest using gist (way) where res = 10;
create index gen_forest_150_gix ON gen_forest using gist (way) where res = 150;
create index gen_forest_600_gix ON gen_forest using gist (way) where res = 600;
