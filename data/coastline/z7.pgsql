SELECT
  row_number() over() AS gid,
  ST_AsBinary(st_union(geom)) AS geom,
  'coastline' AS kind
FROM
  coastline
WHERE
  geom && !BBOX!
