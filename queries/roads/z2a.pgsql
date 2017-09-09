SELECT
  way AS __geometry__,
  CASE
    WHEN highway is not null THEN highway
    WHEN railway is not null THEN coalesce(service, railway)
  END AS kind,
  name,
  ref
FROM
  planet_osm_line
WHERE
  (highway IN ('motorway', 'motorway_link',
               'trunk', 'trunk_link',
               'primary', 'primary_link',
               'secondary', 'secondary_link',
               'tertiary', 'tertiary_link',
               'unclassified',
               'living_street',
               'residential',
               'pedestrian',
               'track')
   or
   (railway IN ('rail') and service is null))
  and way && !bbox!
