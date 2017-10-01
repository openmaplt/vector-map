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
      WHEN "natural" = 'wetland'
        THEN 'wetland'
      WHEN leisure = 'park'
        THEN 'park'
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    landuse IN ('forest', 'residential', 'commercial', 'industrial', 'meadow', 'farmland', 'allotments', 'cemetery', 'garages') OR
   "natural" = 'wetland' OR
   leisure = 'park'
  )
