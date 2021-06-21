drop table if exists gen_building;
drop sequence if exists gen_building_seq;
create sequence gen_building_seq;

-----------------------------
-- Typify smaller buildings
-----------------------------
create or replace function gen_building_temp(bg geometry, bw integer, br integer, rid bigint) returns geometry as $$
declare
c record;
hw integer = bw / 2;
b geometry;
g geometry;
azimuth float;
cnt integer;
e geometry = st_geomfromewkt('SRID=3857;POLYGON((0 0, 1 0, 0 1, 0 0))');
bgc geometry = st_centroid(bg);
begin
  b = st_geomfromewkt(concat('SRID=3857;POLYGON((-', hw, ' -', hw, ', ', hw, ' -', hw, ', ', hw, ' ', hw, ', -', hw, ' ', hw, ', -', hw, ' -', hw, '))'));
  azimuth = 100;
  for c in (select st_closestpoint(way, bgc) closest
              from planet_osm_line
             where highway in ('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified', 'residential', 'living_street', 'track')
               and st_dwithin(bgc, way, bw * 100)
            order by way <-> bgc
            limit 1) loop
    azimuth = st_azimuth(bgc, c.closest);
  end loop;
  if azimuth = 100 then
    azimuth = 0;
  end if;
  g = st_translate(st_rotate(b, -azimuth), st_x(bgc), st_y(bgc));
  select count(1) into cnt
    from gen_building
   where st_intersects(way, st_buffer(g, bw/2))
     and st_dwithin(g, way, bw)
     and id < rid
     and res = br;
  if cnt = 0 then
    return st_multi(g);
  else
    return st_multi(e);
  end if;
end$$ language plpgsql stable;

------
-- 5
------
-- Selection
create unlogged table gen_building as
  select nextval('gen_building_seq') AS id
        ,0 AS way_area
        ,5 AS res
        ,''::text AS status
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(b.way, 5.00)), 3)::geometry(MultiPolygon, 3857) as way
    from planet_osm_polygon b
   where b.building is not null
     and b.building != 'ruins';

create index gen_buildings_gix on gen_building using gist(way);

-- Remove buildings which are smaller than 25m2
delete from gen_building b
 where res = 5
   and st_area(way) < 25
/*   and exists (select 1
                 from gen_building n
                where st_dwithin(n.way, b.way, 250)
                  and n.id != b.id
                  and res = 5)*/;

-- Aggregation
update gen_building set way = st_multi(st_buffer(way, 0)) where res = 5 and st_area(way) >= 25;

-- Aggregation/Simplification
update gen_building set status = 'DONE', way = st_multi(stc_simplify_building(way, 5)) where res = 5 and st_area(way) >= 25;

-- delete null geometries TODO: HOW DOES THIS HAPPEN?
delete from gen_building where way is null;

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
select 'resolution 10';
insert into gen_building
  select nextval('gen_building_seq') AS id
        ,0 AS way_area
        ,10 AS res
        ,''::text AS status
        ,way as way
    from gen_building
   where res = 5
  order by st_area(way) desc, id;

-- Aggregation/Simplification
update gen_building set status = 'DONE', way = st_multi(stc_simplify_building(way, 10)) where res = 10 and st_area(way) >= 100;

-- Fix invalid geometries
-- (This should eventually be done properly in simplification algorithm)
do $$declare
c record;
begin
  for c in (select id from gen_building where not st_isvalid(way) and res = 10 and st_area(way) >= 100) loop
    raise notice '=== Invalid geometry for gen_building.id=%', c.id;
    update gen_building set way = st_makevalid(way) where id = c.id;
  end loop;
end$$;

update gen_building set way = gen_building_temp(way, 10, 10, id), status = 'TYP' where res = 10 and status = '';
delete from gen_building where res = 10 and st_area(way) < 1;

-------
-- 20
-------
select 'resolution 20';
insert into gen_building
  select nextval('gen_building_seq') AS id
        ,0 AS way_area
        ,20 AS res
        ,''::text AS status
        ,way as way
    from gen_building
   where res = 10
  order by st_area(way) desc, id;

-- Aggregation/Simplification
update gen_building set status = 'DONE', way = st_multi(stc_simplify_building(way, 20)) where res = 20 and st_area(way) >= 400;

-- Fix invalid geometries
-- (This should eventually be done properly in simplification algorithm)
do $$declare
c record;
begin
  for c in (select id from gen_building where not st_isvalid(way) and res = 20 and st_area(way) >= 400) loop
    raise notice '=== Invalid geometry for gen_building.id=%', c.id;
    update gen_building set way = st_makevalid(way) where id = c.id;
  end loop;
end$$;

update gen_building set way = gen_building_temp(way, 20, 20, id), status = 'TYP' where res = 20 and status = '';
delete from gen_building where res = 20 and st_area(way) < 1;

-------
-- 40
-------
select 'resolution 40';
insert into gen_building
  select nextval('gen_building_seq') AS id
        ,0 AS way_area
        ,40 AS res
        ,''::text AS status
        ,way as way
    from gen_building
   where res = 20
  order by st_area(way) desc, id;

-- Aggregation/Simplification
update gen_building set status = 'DONE', way = st_multi(stc_simplify_building(way, 40)) where res = 40 and st_area(way) >= 1600;

-- Fix invalid geometries
-- (This should eventually be done properly in simplification algorithm)
do $$declare
c record;
begin
  for c in (select id from gen_building where not st_isvalid(way) and res = 40 and st_area(way) >= 1600) loop
    raise notice '=== Invalid geometry for gen_building.id=%', c.id;
    update gen_building set way = st_makevalid(way) where id = c.id;
  end loop;
end$$;

update gen_building set way = gen_building_temp(way, 40, 40, id), status = 'TYP' where res = 40 and status = '';
delete from gen_building where res = 40 and st_area(way) < 1;

----------------
-- Update area
----------------
update gen_building set way_area = st_area(way);

drop function gen_building_temp;
