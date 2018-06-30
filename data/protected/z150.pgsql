SELECT
  id AS gid,
  ST_AsBinary(way) AS geom,
  'national_park' AS kind,
  name
FROM
  gen_protected
WHERE
  way && !BBOX! AND
  res = 150

