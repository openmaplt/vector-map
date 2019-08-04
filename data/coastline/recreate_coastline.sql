drop table if exists coastline;
create table coastline as
  select row_number() over() as gid,
         0 as res,
         geom
    from coastline_tmp
   where st_distance(geom, st_setsrid(st_makepoint(2350000,7500000),3857)) < 300000;

insert into coastline
  select gid + 100,
         10,
         st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(geom, 5), -5), 10)))
    from coastline
   where res = 0;

insert into coastline
  select gid + 200,
         150,
         st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(geom, 75), -75), 150)))
    from coastline
   where res = 10;

insert into coastline
  select gid + 300,
         600,
         st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(geom, 300), -300), 600)))
    from coastline
   where res = 150;

do $$declare
c record;
g geometry;
s1 geometry = st_geomfromtext('LINESTRING(2347084 7504769,2346970 7504048)',3857);
s2 geometry = st_geomfromtext('LINESTRING(2352223 7487342,2354650 7487405)',3857);
s3 geometry = st_geomfromtext('LINESTRING(2321601 7391431,2359306 7391055)',3857);
s4 geometry = st_geomfromtext('LINESTRING(2226596 7348756,2224308 7518097)',3857);
s5 geometry = st_geomfromtext('LINESTRING(2347399 7440372,2365634 7440050)',3857);
i integer;
n integer;
zi integer;
z integer;
gi integer;
begin
  for zi in 1..4 loop
    if     zi = 1 then z = 0;
    elseif zi = 2 then z = 10;
    elseif zi = 3 then z = 150;
    elseif zi = 4 then z = 600;
    end if;
    select gid into gi from coastline where res = z;
    select geom into g from coastline where gid = gi and res = z;
    delete from coastline where gid = gi and res = z;
    g = st_split(g, s1);
    g = st_split(g, s2);
    g = st_split(g, s3);
    g = st_split(g, s4);
    g = st_split(g, s5);
    select max(gid) into n from coastline where res = z;
    for c in 1..st_numgeometries(g) loop
      n = n + 1;
      insert into coastline values (n, z, st_multi(st_geometryn(g, c)));
    end loop;
  end loop;
end$$;

create index coastline_geometry on coastline using gist(geom);
