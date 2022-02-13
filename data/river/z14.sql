SELECT
  id AS gid,
  ST_AsMVTGeom(way,!BBOX!) AS geom,
  id,
  name,
  kind
FROM
  poi_river_gen
WHERE
  way && !BBOX!
