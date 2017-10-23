SELECT
  way AS __geometry__,
  (
    CASE
      WHEN waterway = 'river'
        THEN 'river'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  waterway = 'river'

UNION ALL

SELECT
  st_union(way) AS __geometry__,
  (
    CASE
      WHEN "natural" = 'water'
        THEN 'water'
      WHEN landuse = 'reservoir'
        THEN 'lake'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    "natural" = 'water' OR
    landuse = 'reservoir'
  ) AND
  way_area >= 10000000
GROUP BY
  kind,
  coalesce("name:lt", name)
