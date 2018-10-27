SELECT
  id AS gid,
  st_asbinary(way) AS geom,
  coalesce(basin, 0) as basin,
  waterway,
  name
FROM
  upiu_baseinai
WHERE
  way && !BBOX!
