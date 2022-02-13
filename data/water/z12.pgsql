SELECT
  max(osm_id) AS gid,
  st_asmvtgeom(st_union(way),!BBOX!) AS geom,
  'water' AS kind,
  null AS name,
  null AS virtual
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  waterway = 'riverbank' AND
  way_area >= 12800
GROUP BY
  kind

UNION ALL

SELECT
  id AS gid,
  st_asmvtgeom(way,!BBOX!) geom,
  'water' AS kind,
  null AS name,
  null AS virtual
FROM
  gen_water
WHERE
  way && !BBOX! AND
  res = 10 AND
  way_area >= 12800
