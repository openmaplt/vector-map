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
      WHEN "natural" = 'wetland'
        THEN 'wetland'
    END
  )   AS kind
FROM
  planet_osm_polygon
WHERE
  landuse IN ('forest', 'residential', 'commercial', 'industrial', 'meadow', 'farmland')
  OR "natural" IN ('wetland')
