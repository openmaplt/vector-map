create or replace view t_bicycle_13 as
SELECT
  max(osm_id) AS id,
  st_asbinary(st_linemerge(st_collect(way))) AS geometry,
  route AS kind,
  network,
  name,
  distance
FROM
  planet_osm_line
WHERE
  route IN ('bicycle')
GROUP BY
  route, network, name, distance

UNION ALL

SELECT
  max(osm_id),
  st_asbinary(st_linemerge(st_collect(way))),
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
