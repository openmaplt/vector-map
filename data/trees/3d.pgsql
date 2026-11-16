SELECT
  osm_id AS gid,
  st_asmvtgeom(way, !BBOX!) AS geom,
  'tree' AS kind,
  cast(substring(height from '^[0-9]+(?:[.][0-9]+)?') AS real) AS height
FROM
  planet_osm_point
WHERE
  way && !BBOX! AND
  "natural" = 'tree'

UNION ALL

SELECT
  osm_id,
  st_asmvtgeom(way, !BBOX!),
  'tree_row',
  cast(substring(height from '^[0-9]+(?:[.][0-9]+)?') AS real)
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  "natural" = 'tree_row'
