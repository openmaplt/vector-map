SELECT
  id AS gid,
  ST_AsBinary(way) AS geom,
  id,
  name,
  kind
FROM
  poi_river
WHERE
  way && !BBOX!
