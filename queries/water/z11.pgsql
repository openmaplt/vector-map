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
  )   AS kind
FROM
  planet_osm_line
WHERE
  waterway IN ('dock', 'canal', 'river', 'stream')

UNION ALL

SELECT
  way AS __geometry__,
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
  )   AS kind
FROM
  planet_osm_polygon
WHERE
  waterway IN ('riverbank', 'dock')
  OR "natural" IN ('water', 'bay')
  OR landuse IN ('basin', 'reservoir')
  OR amenity = 'swimming_pool' OR leisure = 'swimming_pool'