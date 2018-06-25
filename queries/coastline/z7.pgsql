SELECT
  1 AS __id__,
  st_buffer(st_union(geom), 10) AS __geometry__,
  'coastline' AS kind
FROM
  coastline
WHERE
  geom && !bbox! AND
  res = 600
