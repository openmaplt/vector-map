SELECT
  way AS __geometry__,
  name,
  (
    CASE
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'fast_food'
      THEN 'fast_food'
    WHEN amenity = 'pub'
      THEN 'beer'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    ELSE 'marker'
    END
  ) AS kind,
  CASE WHEN real_ale like '%lager%' THEN 'y' ELSE 'n' END AS style_lager,
  CASE WHEN real_ale like '%ale%'   THEN 'y' ELSE 'n' END AS style_ale,
  CASE WHEN real_ale like '%stout%' THEN 'y' ELSE 'n' END AS style_stout,
  CASE WHEN real_ale like '%ipa%'   THEN 'y' ELSE 'n' END AS style_ipa,
  official_name,
  alt_name,
  opening_hours,
  website,
  image,
  "ref:lt:kpd" AS heritage,
  height,
  wikipedia,
  fee,
  email,
  phone,
  "addr:city" AS city,
  "addr:street" AS street,
  "addr:housenumber" AS housenumber
FROM
  planet_osm_point
WHERE
  way && !bbox! AND
  (
    amenity IN ('bar',
                'cafe',
                'fast_food',
                'pub',
                'restaurant') OR
    shop = 'alcohol'
  ) AND
  real_ale is not null

UNION ALL

SELECT
  st_centroid(way) AS __geometry__,
  name,
  (
    CASE
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'fast_food'
      THEN 'fast_food'
    WHEN amenity = 'pub'
      THEN 'beer'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    ELSE 'marker'
    END
  ) AS kind,
  CASE WHEN real_ale like '%lager%' THEN 'y' ELSE 'n' END AS style_lager,
  CASE WHEN real_ale like '%ale%'   THEN 'y' ELSE 'n' END AS style_ale,
  CASE WHEN real_ale like '%stout%' THEN 'y' ELSE 'n' END AS style_stout,
  CASE WHEN real_ale like '%ipa%'   THEN 'y' ELSE 'n' END AS style_ipa,
  official_name,
  alt_name,
  opening_hours,
  website,
  image,
  "ref:lt:kpd" AS heritage,
  height,
  wikipedia,
  fee,
  email,
  phone,
  "addr:city" AS city,
  "addr:street" AS street,
  "addr:housenumber" AS housenumber
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    amenity IN ('bar',
                'cafe',
                'fast_food',
                'pub',
                'restaurant') OR
    shop = 'alcohol'
  ) AND
  real_ale is not null
