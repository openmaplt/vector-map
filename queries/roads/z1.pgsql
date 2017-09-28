SELECT
  way AS __geometry__,
  highway AS kind,
  ref
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  highway IN ('motorway', 'trunk', 'primary')
