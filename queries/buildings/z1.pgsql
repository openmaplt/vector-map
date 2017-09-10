SELECT
  way AS __geometry__,
  building AS kind,
  coalesce(name, "addr:housename", "addr:housenumber") AS name
FROM
  planet_osm_polygon
WHERE
  building is not null
  and way && !bbox!
