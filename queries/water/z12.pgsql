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
  waterway IN ('dock', 'canal', 'river', 'stream') AND
  "waterway:name" is null

UNION ALL

SELECT
  st_union(way) AS __geometry__,
  'water' AS kind,
  null AS name
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  waterway = 'riverbank' AND
  way_area >= 50000
GROUP BY
  kind

UNION ALL

SELECT
  way __geometry__,
  'water' AS kind,
  null AS name
FROM
  gen_water
WHERE
  way && !bbox! AND
  res = 10 AND
  way_area >= 50000
