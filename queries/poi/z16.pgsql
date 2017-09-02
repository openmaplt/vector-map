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
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'attraction'
      THEN 'attraction'
    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    WHEN shop = 'bakery'
      THEN 'bakery'
  END AS kind,
  opening_hours
FROM
  planet_osm_point
WHERE
  amenity in ('cafe', 'restaurant', 'pub', 'bar', 'bank') or
  tourism in ('museum', 'attraction') or
  shop in ('alcohol', 'bakery')

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
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'attraction'
      THEN 'attraction'
    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    WHEN shop = 'bakery'
      THEN 'bakery'
  END AS kind,
  opening_hours
FROM
  planet_osm_polygon
WHERE
  amenity in ('cafe', 'restaurant', 'pub', 'bar', 'bank') or
  tourism in ('museum', 'attraction') or
  shop in ('alcohol', 'bakery')
