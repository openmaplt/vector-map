SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  route AS kind,
  network,
  name,
  distance
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  route IN ('bicycle')
GROUP BY
  route, network, name, distance

UNION ALL

SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  (
  CASE
    WHEN (highway = 'cycleway') or (highway = 'path' and bicycle = 'designated')
      THEN 'cycleway'
    ELSE
      coalesce(cycleway, "cycleway:both", "cycleway:left", "cycleway:right", bicycle)
  END
  ) AS kind,
  'ways' AS network,
  name,
  null AS distance
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  (cycleway is not null OR
   "cycleway:left" is not null OR
   "cycleway:right" is not null OR
   "cycleway:both" is not null OR
   bicycle = 'yes' OR
   highway = 'cycleway' OR
   (highway = 'path' and bicycle = 'designated')
  )
GROUP BY
  name, cycleway, "cycleway:both", "cycleway:left", "cycleway:right", bicycle, highway
