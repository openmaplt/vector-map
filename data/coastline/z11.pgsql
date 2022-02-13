SELECT
  row_number() over() AS gid,
  ST_AsMVTGeom(ST_Union(ST_Intersection(geom, !BBOX!)),!BBOX!) AS geom,
  'coastline' AS kind
FROM
  coastline
WHERE
  geom && !BBOX! AND
  res = 10
