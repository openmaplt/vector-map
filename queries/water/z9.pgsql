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
    END
  ) AS kind,
  coalesce("name:lt", name) AS name
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  waterway IN ('dock', 'canal', 'river')

UNION ALL

SELECT
  st_union(way) AS __geometry__,
  (
    CASE
      WHEN waterway = 'riverbank'
        THEN 'water'
      WHEN landuse = 'basin'
        THEN 'basin'
    END
  ) AS kind,
  null AS name
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  waterway = 'riverbank' AND
  way_area >= 5000000
GROUP BY
  kind

UNION ALL

SELECT
  way AS __geometry__,
  'water' AS kind,
  null AS name
FROM
  gen_water
WHERE
  way && !bbox! AND
  res = 150 AND
  way_area >= 5000000
