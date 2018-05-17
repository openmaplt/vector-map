SELECT
  way AS __geometry__,
  (
    CASE
      WHEN waterway = 'river'
        THEN 'river'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name,
  "waterway:name" AS wname
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  waterway = 'river'

UNION ALL

SELECT
  st_union(way) AS __geometry__,
  'water' AS kind,
  null AS name,
  null AS wname
FROM
  gen_water
WHERE
  way && !bbox! AND
  res = 600 AND
  way_area >= 5000000
GROUP BY
  kind
