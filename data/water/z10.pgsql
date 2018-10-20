SELECT
  osm_id AS gid,
  st_asbinary(way) AS geom,
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
  way && !BBOX! AND
  waterway IN ('dock', 'canal', 'river') AND
  "waterway:name" is null

UNION ALL

SELECT
  row_number() over() AS gid,
  st_asbinary(st_union(way)) AS geom,
  'water' AS kind,
  null AS name
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  waterway = 'riverbank' AND
  way_area >= 500000

UNION ALL

SELECT
  (row_number() over()) + 1000 AS gid,
  st_asbinary(st_union(way)) AS geom,
  'water' AS kind,
  null AS name
FROM
  gen_water
WHERE
  way && !BBOX! AND
  res = 150 AND
  way_area >= 500000
