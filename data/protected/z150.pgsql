SELECT
  id AS gid,
  ST_AsMVTGeom(way,!BBOX!) AS geom,
  'national_park' AS kind,
  name
FROM
  gen_protected
WHERE
  way && !BBOX! AND
  res = 150

