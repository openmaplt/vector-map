SELECT
  gid AS gid,
  st_asbinary(geom) AS geom,
  kind AS kind
FROM
  details_poly
WHERE
  geom && !BBOX! AND
  kind = 'stadium'
