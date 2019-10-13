SELECT
  id AS gid,
  st_asbinary(way) AS geom,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !BBOX! AND
  res = 600 AND
  way_area >= 3276800
