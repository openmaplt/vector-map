SELECT
  way AS __geometry__,
  building AS kind
FROM
  planet_osm_polygon
WHERE
  building is not null
  and way && !bbox!
