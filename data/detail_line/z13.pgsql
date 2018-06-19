SELECT
  gid AS gid,
  st_asbinary(geom) AS geom,
  kind AS kind
FROM
  details_line
WHERE
  geom && !BBOX! AND
  kind = 'cutline'
