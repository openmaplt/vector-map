SELECT
  gid,
  st_asbinary(st_pointonsurface(geom)) AS geom,
  'dra' AS kind,
  pavadinimas
FROM
  vstt_draustiniai
WHERE
  geom && !BBOX! AND
  zoom <= !zoom!

UNION ALL

SELECT
  gid,
  st_asbinary(st_pointonsurface(geom)) AS geom,
  'par' AS kind,
  pavadinimas
FROM
  vstt_parkai
WHERE
  geom && !BBOX! AND
  zoom <= !zoom!