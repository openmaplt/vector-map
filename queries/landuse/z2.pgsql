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
      WHEN "natural" = 'wetland'
        THEN 'wetland'
      WHEN leisure = 'park'
        THEN 'park'
    END
  )   AS kind
FROM
  planet_osm_polygon
WHERE
  landuse IN ('forest', 'residential', 'commercial', 'industrial')
  OR "natural" IN ('wetland')
  OR leisure IN ('park')
