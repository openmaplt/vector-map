SELECT
  max(osm_id) AS gid,
  st_asmvtgeom(st_union(way),!BBOX!) AS geom,
  (
    CASE
      WHEN water = 'river'
        THEN 'water'
      WHEN landuse = 'basin'
        THEN 'basin'
    END
  ) AS kind,
  null AS name,
  null AS virtual
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  water = 'river' AND
  way_area >= 819200
GROUP BY
  kind

UNION ALL

SELECT
  id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
  'water' AS kind,
  null AS name,
  null AS virtual
FROM
  gen_water
WHERE
  way && !BBOX! AND
  res = 150 AND
  way_area >= 819200
