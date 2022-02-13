SELECT
  gid AS gid,
  ST_AsMVTGeom(geom,!BBOX!) AS geom,
  kind AS kind,
  highway
FROM
  details_line
WHERE
  geom && !BBOX!
