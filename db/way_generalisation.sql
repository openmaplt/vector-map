--------------------
-- Laikina lentelė
--------------------
drop table if exists gen_ways_tmp;
create table gen_ways_tmp (
id bigint
);
select addgeometrycolumn('gen_ways_tmp', 'way', 3857, 'MULTILINESTRING', 2);

---------------------------------------------------
-- Galutinis apdorojimas
-- Multiline padalinamas į line + supaprastinimas
---------------------------------------------------
create or replace function process(p_type text, p_subtype text) returns text as $$
declare
  c record;
  i integer;
  s bigint := 1;
begin
  delete from gen_ways where type = p_type and coalesce(subtype, '!@#') = coalesce(p_subtype, '!@#');

  for c in (select id, st_linemerge(way) as way from gen_ways_tmp) loop
    for i in 1..st_numgeometries(c.way) loop
      insert into gen_ways (id, type, subtype, way) values (s, p_type, p_subtype, st_simplifypreservetopology(st_geometryn(c.way, i), 20));
      s := s + 1;
    end loop;
  end loop;

  return 'Tvarka';
end
$$ language plpgsql;

------------------
-- Geležinkeliai
------------------
insert into gen_ways_tmp (id, way)
  select 1, st_approximatemedialaxis(st_simplifypreservetopology(st_union(st_buffer(way, 40, 'quad_segs=2 join=bevel')), 5))
    from planet_osm_line
   where railway = 'rail'
     and service is null;
update gen_buffers set way = st_buffer(way, -5);

select process('rail', 'rail');

delete from gen_ways_tmp;

-----------
-- Keliai
-----------
do $$
declare
  c record;
  cc record;
  i integer;
  t text;
  s integer := 1;
begin
  for c in (select distinct highway, coalesce(ref, '!@#') as ref
              from planet_osm_line
             where highway in ('motorway', 'trunk', 'primary')) loop
    raise notice 'highway=% ref=%', c.highway, c.ref;
    insert into gen_ways_tmp (id, way)
      select 1, st_approximatemedialaxis(st_simplifypreservetopology(st_union(st_buffer(way, 40, 'quad_segs=2 join=bevel')), 5))
        from planet_osm_line
       where highway in ('motorway', 'trunk', 'primary')
         and coalesce(ref, '!@#') = c.ref;

    t := process(c.highway, c.ref);

    delete from gen_ways_tmp;
  end loop;
  update gen_ways set subtype = null where subtype = '!@#';
end;
$$;

------------------
-- Susitvarkymas
------------------
drop table gen_ways_tmp;
