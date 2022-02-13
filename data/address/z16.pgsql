SELECT
  ABS(osm_id) AS gid,
  CASE WHEN osm_id < 0 THEN 'r' ELSE 'w' END AS __type__,
  st_asmvtgeom(ST_PointOnSurface(way),!BBOX!) AS geom,
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
  osm_id AS gid,
  'n' AS __type__,
  st_asmvtgeom(way,!BBOX!) as geom,
  "addr:housenumber" as housenumber,
  "addr:housename" as name,
  "addr:street" as street,
  "addr:city" as city,
  "addr:postcode" as post_code
FROM
  planet_osm_point
WHERE
  way && !BBOX! AND
  "addr:housenumber" IS NOT NULL and "addr:contact" IS NULL
