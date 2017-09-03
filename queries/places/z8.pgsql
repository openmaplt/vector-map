SELECT
  way AS __geometry__,
  coalesce("name:lt", name) AS name,
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
  (place IN ('country', 'state', 'city') OR (place = 'town' AND rank = '0'))