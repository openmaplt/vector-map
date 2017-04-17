SELECT
  way       AS __geometry__,
  (
    CASE WHEN highway = 'motorway'
      THEN 'highway'
    WHEN highway IN ('trunk', 'primary')
      THEN 'major_road' END
  )         AS kind
FROM
  planet_osm_line
WHERE
  highway IN ('motorway', 'trunk', 'primary')