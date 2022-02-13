SELECT
  row_number() over() AS gid,
  st_asmvtgeom(st_union(way),!BBOX!) AS geom,
  'water' AS kind,
  null AS name,
  null AS virtual
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  waterway = 'riverbank' AND
  way_area >= 204800

UNION ALL

SELECT
  (row_number() over()) + 1000 AS gid,
  st_asmvtgeom(st_union(way),!BBOX!) AS geom,
  'water' AS kind,
  null AS name,
  null AS virtual
FROM
  gen_water
WHERE
  way && !BBOX! AND
  res = 150 AND
  way_area >= 204800
