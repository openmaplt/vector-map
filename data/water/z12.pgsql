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
      WHEN waterway = 'stream'
        THEN 'stream'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name,
  case when "waterway:speed" is null then 'N' else 'Y' end as virtual
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  waterway IN ('dock', 'canal', 'river', 'stream')

UNION ALL

SELECT
  max(osm_id) AS gid,
  st_asbinary(st_union(way)) AS geom,
  'water' AS kind,
  null AS name
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  waterway = 'riverbank' AND
  way_area >= 25000
GROUP BY
  kind

UNION ALL

SELECT
  id AS gid,
  st_asbinary(way) geom,
  'water' AS kind,
  null AS name
FROM
  gen_water
WHERE
  way && !BBOX! AND
  res = 10 AND
  way_area >= 25000
