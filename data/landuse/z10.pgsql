SELECT
  osm_id AS gid,
  st_asbinary(way) AS geom,
  (
    CASE
      WHEN landuse = 'residential'
        THEN 'residential'
      WHEN landuse = 'commercial'
        THEN 'commercial'
      WHEN landuse = 'industrial'
        THEN 'industrial'
      WHEN landuse = 'meadow' or "natural" = 'heath'
        THEN 'meadow'
      WHEN landuse = 'farmland'
        THEN 'farmland'
      WHEN landuse = 'allotments'
        THEN 'allotments'
      WHEN landuse = 'cemetery'
        THEN 'cemetery'
      WHEN landuse = 'garages'
        THEN 'garages'
      WHEN "natural" = 'wetland' AND "wetland" = 'marsh'
        THEN 'marsh'
      WHEN "natural" = 'wetland' AND "wetland" = 'swamp'
        THEN 'swamp'
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  (
    landuse IN ('residential', 'meadow', 'farmland', 'allotments') OR
   "natural" in ('wetland', 'heath')
  ) AND
  way_area >= 500000

UNION ALL

SELECT
  id,
  st_asbinary(way) AS geometry,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !BBOX! AND
  res = 150 AND
  way_area >= 500000
