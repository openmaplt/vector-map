SELECT
  way AS __geometry__,
  coalesce("name:lt", name) AS name,
  (
    CASE
      WHEN place = 'town' AND rank = '0'
        THEN 'town'
      WHEN place = 'town' AND rank = '10'
        THEN 'little_town'
      WHEN place = 'town' AND rank = '20'
        THEN 'railway_station'
      ELSE place
    END
  ) AS kind
FROM
  planet_osm_point
WHERE
  way && !bbox! AND
  name IS NOT NULL AND
  place IN ('city', 'town', 'village')
ORDER BY
  coalesce(population, 0) desc

UNION ALL

SELECT
  ST_PointOnSurface(way) AS __geometry__,
  coalesce("name:lt", name) AS name,
  'water' AS kind
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  name IS NOT NULL AND
  ("natural" = 'water' OR landuse = 'reservoir') AND
  way_area >= 500000
