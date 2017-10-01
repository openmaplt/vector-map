SELECT
  way AS __geometry__,
  landuse AS kind
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  landuse = 'forest' AND
  way_area >= 10000000