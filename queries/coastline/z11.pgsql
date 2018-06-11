SELECT
  gid AS __id__,
  st_union(geom) AS __geometry__,
  'coastline' AS kind
FROM
  coastline
WHERE
  geom && !bbox! AND
  res = 10
GROUP BY
  gid
