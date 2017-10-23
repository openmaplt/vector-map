SELECT
  ST_PointOnSurface(way) AS __geometry__,
  coalesce("name:lt", name) AS name,
  'park' AS kind,
  website,
  wikipedia
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  name IS NOT NULL AND
  boundary = 'national_park' AND
  way_area >= 1000000
