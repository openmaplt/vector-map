SELECT
  way AS __geometry__,
  name,
  CASE
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN amenity = 'pub'
      THEN 'pub'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN tourism = 'museum'
      THEN 'museum'
  END AS kind,
  opening_hours
FROM
  planet_osm_point
WHERE
  amenity in ('cafe', 'restaurant', 'pub', 'bar') or
  tourism in ('museum')

UNION ALL

SELECT
  st_centroid(way) AS __geometry__,
  name,
  CASE
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN amenity = 'pub'
      THEN 'pub'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN tourism = 'museum'
      THEN 'museum'
  END AS kind,
  opening_hours
FROM
  planet_osm_polygon
WHERE
  amenity in ('cafe', 'restaurant', 'pub', 'bar') or
  tourism in ('museum')