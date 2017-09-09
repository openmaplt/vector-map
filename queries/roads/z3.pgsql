SELECT
  way AS __geometry__,
  CASE
    WHEN highway is not null THEN highway
    WHEN railway is not null THEN coalesce(service, railway)
  END AS kind,
  name,
  ref,
  CASE
    WHEN tunnel is not null
      THEN 'yes'
    ELSE 'no'
  END as is_tunnel,
  CASE
    WHEN bridge is not null
      THEN 'yes'
    ELSE 'no'
  END as is_bridge
FROM
  planet_osm_line
WHERE
  (highway IN ('motorway', 'motorway_link',
               'trunk', 'trunk_link',
               'primary','primary_link',
               'secondary', 'secondary_link',
               'tertiary', 'tertiary_link',
               'unclassified',
               'residential',
               'living_street',
               'pedestrian',
               'service',
               'track',
               'footway',
               'path')
   or
   railway IN ('rail'))
  and way && !bbox!
