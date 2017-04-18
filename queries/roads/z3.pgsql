SELECT
  way AS __geometry__,
  highway AS kind,
  name,
  ref
FROM
  planet_osm_line
WHERE
  highway IN ('motorway',
              'trunk', 'trunk_link',
              'primary','primary_link',
              'secondary', 'secondary_link',
              'tertiary', 'tertiary_link',
              'unclassified',
              'residential',
              'service',
              'footway',
              'path')
  and way && !bbox!