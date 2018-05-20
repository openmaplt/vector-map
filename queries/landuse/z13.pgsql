SELECT
  osm_id AS __id__,
  way AS __geometry__,
  (
    CASE
      WHEN landuse = 'meadow' or "natural" = 'heath'
        THEN 'meadow'
      WHEN landuse = 'orchard'
        THEN landuse
      WHEN "natural" = 'wetland' AND "wetland" = 'marsh'
        THEN 'marsh'
      WHEN "natural" = 'wetland' AND "wetland" = 'swamp'
        THEN 'swamp'
      WHEN "natural" = 'wetland' AND "wetland" = 'reedbed'
        THEN 'reedbed'
      WHEN "natural" in ('beach', 'sand')
        THEN 'sand'
      WHEN "natural" = 'scrub'
        THEN 'scrub'
      WHEN aeroway is not null
        THEN aeroway
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    landuse in ('residential', 'commercial', 'industrial', 'meadow', 'farmland', 'allotments', 'cemetery', 'garages', 'orchard')
    OR "natural" in ('wetland', 'sand', 'beach', 'scrub', 'heath')
    OR aeroway in ('runway')
  ) AND
  way_area >= 10000

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
  way_area >= 10000
