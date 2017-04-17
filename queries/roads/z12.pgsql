SELECT
  way AS __geometry__,
  (
    CASE WHEN highway IN ('motorway', 'motorway_link')
      THEN 'highway'
    WHEN highway IN ('trunk', 'trunk_link', 'primary', 'secondary', 'tertiary')
      THEN 'major_road'
    WHEN highway IN ('residential', 'unclassified', 'road')
      THEN 'minor_road'
    WHEN aeroway = 'runway'
      THEN 'aeroway'
    END
  )   AS kind
FROM
  planet_osm_line
WHERE
  highway IN ('motorway', 'motorway_link')
  OR highway IN ('trunk', 'trunk_link')
  OR highway IN ('primary', 'secondary', 'tertiary')
  OR highway IN ('residential', 'unclassified', 'road')
  OR aeroway = 'runway'