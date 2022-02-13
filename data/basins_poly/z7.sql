SELECT
  id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
  coalesce(basin, 0) as basin
FROM
  upiu_baseinai_plot
WHERE
  way && !BBOX!
