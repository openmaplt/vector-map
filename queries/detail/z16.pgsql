SELECT
  gid AS __id__,
  geom AS __geometry__,
  kind AS kind
FROM
  details_poly
WHERE
  geom && !bbox!

