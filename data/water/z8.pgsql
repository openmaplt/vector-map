SELECT
  osm_id AS gid,
  st_asbinary(way) AS geom,
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
  way && !BBOX! AND
  waterway = 'river' AND
  "waterway:speed" is null

UNION ALL

SELECT
  max(id) AS gid,
  st_asbinary(st_union(way)) AS geom,
  'water' AS kind,
  null AS name
FROM
  gen_water
WHERE
  way && !BBOX! AND
  res = 600 AND
  way_area >= 5000000
GROUP BY
  kind
