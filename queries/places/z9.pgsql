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
  (
    place IN ('country', 'state', 'city') OR
    (place = 'town' AND rank in ('0', '10'))
  )
ORDER BY
  coalesce(population, 0) desc
