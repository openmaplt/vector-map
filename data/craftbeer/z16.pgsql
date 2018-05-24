SELECT
  id,
  id AS __id__,
  __type__,
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
      THEN 'alcohol-shop'
    ELSE 'marker'
    END
  ) AS kind,
  CASE WHEN real_ale like '%lager%' THEN 'y' ELSE 'n' END AS style_lager,
  CASE WHEN real_ale like '%ale%'   THEN 'y' ELSE 'n' END AS style_ale,
  CASE WHEN real_ale like '%stout%' THEN 'y' ELSE 'n' END AS style_stout,
  CASE WHEN real_ale like '%ipa%'   THEN 'y' ELSE 'n' END AS style_ipa,
  CASE WHEN real_ale like '%wheat%' THEN 'y' ELSE 'n' END AS style_wheat,
  CASE WHEN shop = 'alcohol' THEN 'y' ELSE 'n' END AS shop,
  CASE WHEN amenity in ('bar', 'cafe', 'fast_food', 'pub', 'restaurant') THEN 'y' ELSE 'n' END AS drink,
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
  poi
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
ORDER BY
  CASE WHEN amenity in ('bar', 'pub') THEN 1 ELSE 2 END,
  CASE WHEN real_ale like '%lager%' THEN 1 ELSE 0 END +
  CASE WHEN real_ale like '%ale%'   THEN 1 ELSE 0 END +
  CASE WHEN real_ale like '%stout%' THEN 1 ELSE 0 END +
  CASE WHEN real_ale like '%ipa%'   THEN 1 ELSE 0 END +
  CASE WHEN real_ale like '%wheat%' THEN 1 ELSE 0 END desc
