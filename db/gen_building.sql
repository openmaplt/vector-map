drop table if exists gen_building;
drop sequence if exists gen_building_seq;
create sequence gen_building_seq;

------
-- 5
------
-- Selection
create table gen_building as
  select nextval('gen_building_seq') AS id
        ,0 AS way_area
        ,5 AS res
        ,''::text AS status
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(way, 5.00)), 3)::geometry(MultiPolygon, 3857) as way
    from planet_osm_polygon
   where building is not null
     and building != 'ruins';

create index gen_buildings_gix on gen_building using gist(way);

-- Remove buildings which are:
-- a) smaller than 25m2
-- b) not isolated (there are other buildings closer than 250m)
delete from gen_building b
 where res = 5
   and st_area(way) < 25
   and exists (select 1
                 from gen_building n
                where st_dwithin(n.way, b.way, 250)
                  and n.id != b.id
                  and res = 5);

-- Aggregation
update gen_building set way = st_multi(st_buffer(way, 0)) where res = 5;

-- Aggregation/Simplification
update gen_building set status = 'DONE', way = st_multi(stc_simplify_building(way, 5)) where res = 5;

-- Fix invalid geometries
-- (This should eventually be done properly in simplification algorithm)
do $$declare
c record;
begin
  for c in (select id from gen_building where not st_isvalid(way) and res = 5) loop
    raise notice '=== Invalid geometry for gen_building.id=%', c.id;
    update gen_building set way = st_makevalid(way) where id = c.id;
  end loop;
end$$;

-------
-- 10
-------
insert into gen_building
  select nextval('gen_building_seq') AS id
        ,0 AS way_area
        ,10 AS res
        ,''::text AS status
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(way, 10.00)), 3)::geometry(MultiPolygon, 3857) as way
    from gen_building
   where res = 5;

delete from gen_building b
 where res = 10
   and st_area(way) < 100
   and exists (select 1
                 from gen_building n
                where st_dwithin(n.way, b.way, 500)
                  and n.id != b.id
                  and res = 10);

-- Aggregation
update gen_building set way = st_multi(st_buffer(way, 0)) where res = 10;

-- Aggregation/Simplification
update gen_building set status = 'DONE', way = st_multi(stc_simplify_building(way, 10)) where res = 10;

-- Fix invalid geometries
-- (This should eventually be done properly in simplification algorithm)
do $$declare
c record;
begin
  for c in (select id from gen_building where not st_isvalid(way) and res = 10) loop
    raise notice '=== Invalid geometry for gen_building.id=%', c.id;
    update gen_building set way = st_makevalid(way) where id = c.id;
  end loop;
end$$;

-------
-- 20
-------
insert into gen_building
  select nextval('gen_building_seq') AS id
        ,0 AS way_area
        ,20 AS res
        ,''::text AS status
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(way, 20.00)), 3)::geometry(MultiPolygon, 3857) as way
    from gen_building
   where res = 10;


delete from gen_building b
 where res = 20
   and st_area(way) < 400
   and exists (select 1
                 from gen_building n
                where st_dwithin(n.way, b.way, 1000)
                  and n.id != b.id
                  and res = 20);

-- Aggregation
update gen_building set way = st_multi(st_buffer(way, 0)) where res = 20;

-- Aggregation/Simplification
update gen_building set status = 'DONE', way = st_multi(stc_simplify_building(way, 20)) where res = 20;

-- Fix invalid geometries
-- (This should eventually be done properly in simplification algorithm)
do $$declare
c record;
begin
  for c in (select id from gen_building where not st_isvalid(way) and res = 20) loop
    raise notice '=== Invalid geometry for gen_building.id=%', c.id;
    update gen_building set way = st_makevalid(way) where id = c.id;
  end loop;
end$$;

----------------
-- Update area
----------------
update gen_building set way_area = st_area(way);
