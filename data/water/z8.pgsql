SELECT
  max(id) AS gid,
  st_asmvtgeom(st_union(way),!BBOX!) AS geom,
  'water' AS kind,
  null AS name,
  null AS virtual
FROM
  gen_water
WHERE
  way && !BBOX! AND
  res = 600 AND
  way_area >= 3276800
GROUP BY
  kind
