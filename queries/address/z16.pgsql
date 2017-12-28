SELECT
  ABS(osm_id) AS id,
  ABS(osm_id) AS __id__,
  CASE WHEN osm_id < 0 THEN 'r' ELSE 'w' END AS __type__,
  ST_PointOnSurface(way) AS __geometry__,
  "addr:housenumber" as housenumber,
  "addr:housename" as name,
  "addr:street" as street,
  "addr:city" as city,
  "addr:postcode" as post_code
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  "addr:housenumber" IS NOT NULL AND "addr:contact" IS NULL
UNION
SELECT
  osm_id AS id,
  osm_id AS __id__,
  'n' AS __type__,
  way as __geometry__,
  "addr:housenumber" as housenumber,
  "addr:housename" as name,
  "addr:street" as street,
  "addr:city" as city,
  "addr:postcode" as post_code
FROM
  planet_osm_point
WHERE
  way && !bbox!
  AND "addr:housenumber" IS NOT NULL and "addr:contact" IS NULL
