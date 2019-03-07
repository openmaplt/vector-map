drop table if exists car_centerline;
create table car_centerline (
id bigint,
osm_id bigint,
name text,
zoom integer,
size integer,
spacing real,
way geometry
);
