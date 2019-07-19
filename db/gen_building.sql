drop table if exists gen_building;
drop sequence if exists gen_building_seq;
create sequence gen_building_seq;

--------------
-- Selection
--------------
create table gen_building as
  select nextval('gen_building_seq') AS id
        ,0 AS way_area
        ,10 AS res
        ,''::text AS status
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(way, 10.00)), 3)::geometry(MultiPolygon, 3857) as way
    from planet_osm_polygon
   where building is not null
     and building != 'ruins';

create index gen_buildings_gix on gen_building using gist(way);

-- Remove buildings which are:
-- a) smaller than 100m2
-- b) not isolated (there are other buildings closer than 500m)
delete from gen_building b
 where st_area(way) < 100
   and exists (select 1
                 from gen_building n
                where st_dwithin(n.way, b.way, 500)
                  and n.id != b.id);

----------------
-- Aggregation
----------------
update gen_building set way = st_multi(st_buffer(way, 0)) where res = 10;

-------------------------------
-- Aggregation/Simplification
-------------------------------
update gen_building set status = 'DONE', way = st_multi(stc_simplify_building(way, 10)) where res = 10;

--------------------------------------------------------------------------
-- Fix invalid geometries
-- (This should eventually be done properly in simplification algorithm)
--------------------------------------------------------------------------
do $$declare
c record;
begin
  for c in (select id from gen_building where not st_isvalid(way) and res = 10) loop
    raise notice '=== Invalid geometry for gen_building.id=%', c.id;
    update gen_building set way = st_makevalid(way) where id = c.id;
  end loop;
end$$;

----------------
-- Update area
----------------
update gen_building set way_area = st_area(way) where res = 10;
