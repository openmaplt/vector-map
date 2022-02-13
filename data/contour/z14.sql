SELECT
  ogc_fid AS gid,
  zemes_h AS height,
  st_asmvtgeom(geom,!BBOX!) AS geom
FROM
  izolinijos
WHERE
  geom && !BBOX!
