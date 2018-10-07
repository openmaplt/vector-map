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
         st_multi(st_simplifypreservetopology(geom, 10))
    from coastline
   where res = 0;

insert into coastline
  select gid + 200,
         150,
         st_multi(st_simplifypreservetopology(geom, 150))
    from coastline
   where res = 10;

insert into coastline
  select gid + 300,
         600,
         st_multi(st_simplifypreservetopology(geom, 600))
    from coastline
   where res = 150;

create index coastline_geometry on coastline using gist(geom);
