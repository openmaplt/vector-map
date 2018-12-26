SELECT
  gid AS gid,
  wkb AS geom,
  kind AS kind
FROM
  details_line
WHERE
  geom && !BBOX! AND
  kind in ('cutline', 'dam')
