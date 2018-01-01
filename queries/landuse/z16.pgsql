SELECT
  way AS __geometry__,
  (
    CASE
      WHEN landuse = 'forest'
        THEN 'forest'
      WHEN landuse = 'residential'
        THEN 'residential'
      WHEN landuse = 'commercial'
        THEN 'commercial'
      WHEN landuse = 'industrial'
        THEN 'industrial'
      WHEN landuse = 'meadow'
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
      WHEN "natural" in ('beach', 'sand')
        THEN 'sand'
      WHEN "natural" = 'scrub'
        THEN 'scrub'
      WHEN leisure = 'park'
        THEN 'park'
      WHEN aeroway is not null
        THEN aeroway
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    landuse in ('forest', 'residential', 'commercial', 'industrial', 'meadow', 'farmland', 'allotments', 'cemetery', 'garages')
    OR "natural" in ('wetland', 'sand', 'beach', 'scrub')
    OR leisure = 'park'
    OR aeroway in ('apron', 'runway')
  )
