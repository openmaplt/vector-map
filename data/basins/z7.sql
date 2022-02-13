SELECT
  id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
  coalesce(basin, 0) as basin,
  waterway,
  name
FROM
  upiu_baseinai
WHERE
  way && !BBOX!
