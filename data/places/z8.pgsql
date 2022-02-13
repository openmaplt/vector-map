SELECT
  osm_id AS gid,
  ST_AsMVTGeom(way,!BBOX!) AS geom,
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
  way && !BBOX! AND
  name IS NOT NULL AND
  (
    place IN ('country', 'state', 'city') OR
    (place = 'town' AND coalesce(rank, '0') in ('0', '10'))
  )
ORDER BY
  coalesce(population::int, 0) desc
