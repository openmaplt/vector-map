drop sequence car_request_seq;
create sequence car_request_seq;
drop table if exists car_requests;
create table car_requests (
id bigint,
type text,
osm_id bigint,
dirty text,
duration integer,
last_update timestamp
);
