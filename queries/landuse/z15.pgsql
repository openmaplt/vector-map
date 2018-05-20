SELECT
  osm_id AS __id__,
  way AS __geometry__,
  (
    CASE
      WHEN landuse = 'meadow' or "natural" = 'heath'
        THEN 'meadow'
      WHEN landuse is not null
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
    landuse in ('forest', 'residential', 'commercial', 'industrial', 'meadow', 'farmland', 'allotments', 'cemetery', 'garages', 'orchard')
    OR "natural" in ('wetland', 'sand', 'beach', 'scrub', 'heath')
    OR aeroway in ('apron', 'runway')
  ) AND
  way_area >= 1000
