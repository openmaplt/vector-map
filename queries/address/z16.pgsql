SELECT
  ST_PointOnSurface(way) AS __geometry__,
  "addr:housenumber" as number,
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
  way as __geometry__,
  "addr:housenumber" as number,
  "addr:housename" as name,
  "addr:street" as street,
  "addr:city" as city,
  "addr:postcode" as post_code
FROM
  planet_osm_point
WHERE
  way && !bbox!
  AND "addr:housenumber" IS NOT NULL and "addr:contact" IS NULL
