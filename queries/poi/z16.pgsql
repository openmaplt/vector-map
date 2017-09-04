SELECT
  way AS __geometry__,
  name,
  CASE
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'cinema'
      THEN 'cinema'
    WHEN amenity = 'fast_food'
      THEN 'fast_food'
    WHEN amenity = 'fire_station'
      THEN 'fire-station'
    WHEN amenity = 'fuel'
      THEN 'fuel'
    WHEN amenity = 'pub'
      THEN 'pub'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'attraction'
      THEN 'attraction'
    WHEN tourism = 'campsite'
      THEN 'camp_site'
    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    WHEN shop = 'bakery'
      THEN 'bakery'
  END AS kind,
  official_name,
  opening_hours,
  website,
  image
FROM
  planet_osm_point
WHERE
  amenity in ('bank', 'bar', 'cafe', 'cinema', 'fast_food', 'fire_station', 'fuel', 'restaurant', 'pub', 'bar', 'bank') or
  tourism in ('museum', 'attraction', 'camp_site') or
  shop in ('alcohol', 'bakery')

UNION ALL

SELECT
  st_centroid(way) AS __geometry__,
  name,
  CASE
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'cinema'
      THEN 'cinema'
    WHEN amenity = 'fast_food'
      THEN 'fast_food'
    WHEN amenity = 'fire_station'
      THEN 'fire-station'
    WHEN amenity = 'fuel'
      THEN 'fuel'
    WHEN amenity = 'pub'
      THEN 'pub'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'attraction'
      THEN 'attraction'
    WHEN tourism = 'campsite'
      THEN 'camp_site'
    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    WHEN shop = 'bakery'
      THEN 'bakery'
  END AS kind,
  official_name,
  opening_hours,
  website,
  image
FROM
  planet_osm_polygon
WHERE
  amenity in ('bank', 'bar', 'cafe', 'cinema', 'fast_food', 'fire_station', 'fuel', 'restaurant', 'pub') or
  tourism in ('museum', 'attraction', 'camp_site') or
  shop in ('alcohol', 'bakery')
