SELECT
  gid AS gid,
  wkb AS geom,
  kind AS kind,
  highway
FROM
  details_line
WHERE
  geom && !BBOX!
