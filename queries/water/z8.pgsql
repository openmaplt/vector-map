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
  'water' AS kind,
  null AS name
FROM
  gen_water
WHERE
  way && !bbox! AND
  res = 600 AND
  way_area >= 10000000
GROUP BY
  kind
