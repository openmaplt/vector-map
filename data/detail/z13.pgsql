SELECT
  osm_id AS gid,
  ST_AsBinary(way) AS geom,
  man_made AS kind
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  man_made = 'cutline'

UNION ALL

SELECT
  osm_id,
  ST_AsBinary(way),
  leisure AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  leisure in ('stadium', 'pitch')
