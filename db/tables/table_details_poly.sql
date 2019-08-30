drop materialized view if exists details_poly;
create materialized view details_poly (
  gid,
  wkb,
  geom,
  kind
) as
SELECT
  osm_id,
  ST_AsBinary(way),
  way,
  coalesce(leisure, landcover) AS kind
FROM
  planet_osm_polygon
WHERE
  leisure in ('stadium', 'pitch') or
  landcover in ('grass', 'trees');
