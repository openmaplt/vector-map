SELECT
  way AS __geometry__,
  building AS kind,
  coalesce(name, "addr:housename") AS name,
  "addr:housenumber" as number,
  coalesce(cast(split_part(height, '.', 1) as integer), coalesce(cast("building:levels" as integer), 2) * 3) AS height
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  building IS NOT NULL
