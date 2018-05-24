SELECT
  ABS(osm_id) AS id,
  CASE WHEN osm_id < 0 THEN 'r' ELSE 'w' END AS __type__,
  ST_AsBinary(ST_PointOnSurface(way)) AS geometry,
  "addr:housenumber" as housenumber,
  "addr:housename" as name,
  "addr:street" as street,
  "addr:city" as city,
  "addr:postcode" as post_code
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  "addr:housenumber" IS NOT NULL AND "addr:contact" IS NULL
UNION
SELECT
  osm_id AS id,
  'n' AS __type__,
  ST_AsBinary(way) as geometry,
  "addr:housenumber" as housenumber,
  "addr:housename" as name,
  "addr:street" as street,
  "addr:city" as city,
  "addr:postcode" as post_code
FROM
  planet_osm_point
WHERE
  way && !BBOX!
  AND "addr:housenumber" IS NOT NULL and "addr:contact" IS NULL