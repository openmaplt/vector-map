SELECT
  osm_id AS __id__,
  way AS __geometry__,
  (
    CASE
      WHEN landuse = 'residential'
        THEN 'residential'
      WHEN landuse = 'meadow' or "natural" = 'heath'
        THEN 'meadow'
      WHEN landuse = 'farmland'
        THEN 'farmland'
      WHEN landuse = 'allotments'
        THEN 'allotments'
      WHEN "natural" = 'wetland' AND "wetland" = 'marsh'
        THEN 'marsh'
      WHEN "natural" = 'wetland' AND "wetland" = 'swamp'
        THEN 'swamp'
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    landuse IN ('residential', 'meadow', 'farmland', 'allotments') OR
   "natural" in ('wetland', 'heath')
  ) AND
  way_area >= 100000

UNION ALL

SELECT
  id AS __id__,
  way AS __geometry__,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !bbox! AND
  res = 10 AND
  way_area >= 100000
