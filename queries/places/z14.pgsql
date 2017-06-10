SELECT
  way AS __geometry__,
  name,
  CASE
    WHEN place='town' and rank='0'
      THEN 'town'
    WHEN place='town' and rank='10'
      THEN 'little_town'
    WHEN place='town' and rank='20'
      THEN 'railway_station'
    ELSE place
  END AS kind,
  population
FROM
  planet_osm_point
WHERE
  name IS NOT NULL AND
  (place IN ('city', 'town', 'village', 'hamlet', 'locality'))
union all
SELECT
  ST_PointOnSurface(way) AS __geometry__,
  name,
  'water' AS kind,
  null AS population
FROM
  planet_osm_polygon
WHERE
  name IS NOT NULL AND
  (natural = 'water' or landuse = 'reservoir')
