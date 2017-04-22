SELECT
  way AS __geometry__,
  (
    CASE
      WHEN landuse = 'forest'
        THEN 'forest'
    END
  )   AS kind
FROM
  planet_osm_polygon
WHERE
  landuse = 'forest'