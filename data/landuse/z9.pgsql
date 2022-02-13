SELECT
  id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !BBOX! AND
  res = 150 AND
  way_area >= 819200
