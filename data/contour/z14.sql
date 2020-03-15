SELECT
  ogc_fid AS gid,
  zemes_h AS height,
  st_asbinary(geom) AS geom
FROM
  izolinijos
WHERE
  geom && !BBOX!
