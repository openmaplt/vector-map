SELECT
  gid AS gid,
  wkb AS geom,
  kind AS kind
FROM
  details_poly
WHERE
  geom && !BBOX! AND
  kind = 'stadium'
