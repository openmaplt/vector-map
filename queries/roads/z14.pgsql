SELECT
  way AS __geometry__,
  (
    CASE WHEN highway IN ('motorway', 'motorway_link')
      THEN 'highway'
    WHEN highway IN ('trunk', 'trunk_link', 'primary', 'primary_link', 'secondary', 'secondary_link', 'tertiary', 'tertiary_link')
      THEN 'major_road'
    WHEN highway IN ('residential', 'unclassified', 'road', 'living_street')
      THEN 'minor_road'
    WHEN highway IN ('pedestrian', 'path', 'track', 'cycleway', 'bridleway', 'footway', 'steps')
      THEN 'path'
    WHEN aeroway = 'runway'
      THEN 'aeroway'
    END
  )   AS kind
FROM
  planet_osm_line
WHERE
  highway IN ('motorway', 'motorway_link')
  OR highway IN ('trunk', 'trunk_link')
  OR highway IN ('primary', 'primary_link')
  OR highway IN ('secondary', 'secondary_link')
  OR highway IN ('tertiary', 'tertiary_link')
  OR highway IN ('living_street', 'pedestrian')
  OR highway IN ('residential', 'unclassified', 'road')
  OR highway IN ('path', 'track', 'cycleway', 'bridleway')
  OR highway IN ('footway', 'steps')
  OR aeroway = 'runway'