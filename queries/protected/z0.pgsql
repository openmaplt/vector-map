SELECT
  way AS __geometry__,
  boundary AS kind,
  name
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  boundary = 'national_park'