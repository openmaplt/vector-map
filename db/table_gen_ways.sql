create table gen_ways (
id bigint,
type text,
subtype text
);
select addgeometrycolumn('gen_ways', 'way', 3857, 'LINESTRING', 2);
