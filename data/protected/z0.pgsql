SELECT
  osm_id AS gid,
  ST_AsMVTGeom(way,!BBOX!) AS geom,
  boundary AS kind,
  name
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  boundary = 'national_park'
