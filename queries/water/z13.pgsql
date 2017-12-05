SELECT
  way AS __geometry__,
  (
    CASE
      WHEN waterway = 'dock'
        THEN 'dock'
      WHEN waterway = 'canal'
        THEN 'canal'
      WHEN waterway = 'river'
        THEN 'river'
      WHEN waterway = 'stream'
        THEN 'stream'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  waterway IN ('dock', 'canal', 'river', 'stream')

UNION ALL

SELECT
  st_union(way) AS __geometry__,
  (
    CASE
      WHEN waterway = 'riverbank'
        THEN 'water'
      WHEN "natural" = 'water'
        THEN 'water'
      WHEN landuse = 'basin'
        THEN 'basin'
      WHEN landuse = 'reservoir'
        THEN 'water'
      WHEN amenity = 'swimming_pool' OR leisure = 'swimming_pool'
        THEN 'swimming_pool'
    END
  ) AS kind,
  null AS name
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    waterway = 'riverbank' OR
    "natural" = 'water' OR
    landuse IN ('basin', 'reservoir') OR
    amenity = 'swimming_pool' OR
    leisure = 'swimming_pool'
  ) AND
  way_area >= 50000
GROUP BY
  kind
