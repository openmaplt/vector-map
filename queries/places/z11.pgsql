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
  (place IN ('city', 'town', 'village'))
