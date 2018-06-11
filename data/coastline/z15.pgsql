SELECT
  row_number() over() AS gid,
  ST_AsBinary(ST_Union(ST_Intersection(geom, !BBOX!))) AS geom,
  'coastline' AS kind
FROM
  coastline
WHERE
  geom && !BBOX! AND
  res = 0
