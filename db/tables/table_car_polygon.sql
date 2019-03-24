drop table if exists car_polygon;
create unlogged table car_polygon (
 id  bigint
,x   integer
,y   integer
,s   text
,w   integer
,way geometry);
create index car_polygon_xy on car_polygon(x, y);
