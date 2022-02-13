SELECT
  gid AS gid,
  ST_AsMVTGeom(geom, !BBOX!) AS geom,
  kind AS kind
FROM
  details_poly
WHERE
  geom && !BBOX! AND
  kind = 'stadium'
