SELECT
  osm_id AS gid,
  ST_AsMVTGeom(ST_PointOnSurface(way),!BBOX!) AS geom,
  coalesce("name:lt", name) AS name,
  'park' AS kind,
  website,
  wikipedia
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  name IS NOT NULL AND
  boundary = 'national_park' AND
  way_area >= 1000000
