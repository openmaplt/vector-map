SELECT
  way AS __geometry__,
  (
    CASE WHEN highway IN ('motorway', 'motorway_link')
      THEN 'highway'
    WHEN highway IN ('trunk', 'primary', 'secondary', 'tertiary')
      THEN 'major_road'
    WHEN aeroway = 'runway'
      THEN 'aeroway'
    END
  )   AS kind
FROM
  planet_osm_line
WHERE
  highway IN ('motorway', 'trunk', 'primary', 'secondary', 'motorway_link', 'tertiary')
  OR aeroway = 'runway'