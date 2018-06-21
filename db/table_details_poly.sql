drop materialized view if exists details_poly;
create materialized view details_poly (
  gid,
  wkt,
  geom,
  kind
) as
SELECT
  osm_id,
  ST_AsBinary(way),
  way,
  leisure AS kind
FROM
  planet_osm_polygon
WHERE
  leisure in ('stadium', 'pitch');
