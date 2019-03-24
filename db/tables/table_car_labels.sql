create sequence car_labels_seq;
drop table if exists car_labels;
create table car_labels(
id bigint,
osm_id bigint,
name text,
zoom integer,
size integer,
spacing real,
way geometry
);
