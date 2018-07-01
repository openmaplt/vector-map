drop table if exists gen_protected;
drop sequence if exists gen_protected_seq;
create sequence gen_protected_seq;

------------------
-- resolution 10
------------------
create table gen_protected as
  select nextval('gen_protected_seq') AS id
        ,0::bigint AS way_area
        ,10 AS res
        ,name
        ,st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 5, 'quad_segs=1'), -5, 'quad_segs=1'), 10))) as way
    from planet_osm_polygon
   where boundary = 'national_park'
     and st_area(st_buffer(way, -5)) > 10;

-------------------
-- resolution 40
-------------------
insert into gen_protected
  select nextval('gen_protected_seq') AS id,
         0,
         40,
         name,
         st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 20, 'quad_segs=1'), -20, 'quad_segs=1'), 40)))
    from gen_protected
   where res = 10
     and st_area(st_buffer(way, -20)) > 40;

-------------------
-- resolution 150
-------------------
insert into gen_protected
  select nextval('gen_protected_seq') AS id,
         0,
         150,
         name,
         st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 75, 'quad_segs=1'), -75, 'quad_segs=1'), 150)))
    from gen_protected
   where res = 40
     and st_area(st_buffer(way, -75)) > 150;

-------------------
-- resolution 600
-------------------
insert into gen_protected
  select nextval('gen_protected_seq') AS id,
         0,
         600,
         name,
         st_makevalid(st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 300, 'quad_segs=1'), -300, 'quad_segs=1'), 600)))
    from gen_protected
   where res = 150
     and st_area(st_buffer(way, -300)) > 600;

update gen_protected set way_area = st_area(way);

create index gen_protected_10_gix ON gen_protected using gist (way) where res = 10;
create index gen_protected_40_gix ON gen_protected using gist (way) where res = 40;
create index gen_protected_150_gix ON gen_protected using gist (way) where res = 150;
create index gen_protected_600_gix ON gen_protected using gist (way) where res = 600;
