SELECT
  way AS __geometry__,
  name,
  place AS kind
FROM
  planet_osm_point
WHERE
  name IS NOT NULL
  AND place IN ('country', 'state', 'province', 'city', 'town')