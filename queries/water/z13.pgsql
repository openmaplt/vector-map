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
        THEN 'riverbank'
      WHEN waterway = 'dock'
        THEN 'dock'
      WHEN "natural" = 'water'
        THEN 'water'
      WHEN "natural" = 'bay'
        THEN 'bay'
      WHEN landuse = 'basin'
        THEN 'basin'
      WHEN landuse = 'reservoir'
        THEN 'lake'
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
    waterway IN ('riverbank', 'dock') OR
    "natural" IN ('water', 'bay') OR
    landuse IN ('basin', 'reservoir') OR
    amenity = 'swimming_pool' OR
    leisure = 'swimming_pool'
  ) AND
  way_area >= 50000
GROUP BY
  kind
