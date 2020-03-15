drop table upiu_baseinai;
drop sequence upiu_baseinai_seq;

create sequence upiu_baseinai_seq;
create table upiu_baseinai (
id bigint,
basin int,
wave int,
name text,
wikipedia text,
waterway text
--way geometry
);
select addgeometrycolumn('upiu_baseinai', 'way', 3857, 'LINESTRING', 2);

drop table if exists upiu_baseinai_plot;
create table upiu_baseinai_plot (
id bigint,
basin int
);
select addgeometrycolumn('upiu_baseinai_plot', 'way', 3857, 'MULTIPOLYGON', 2);
