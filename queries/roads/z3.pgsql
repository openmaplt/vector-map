SELECT
  way AS __geometry__,
  (
    CASE
      WHEN highway IS NOT NULL
        THEN highway
      WHEN railway IS NOT NULL
        THEN coalesce(service, railway)
      WHEN aeroway IS NOT NULL
        THEN aeroway
    END
  ) AS kind,
  name,
  ref,
  (
    CASE
      WHEN tunnel IS NOT NULL
        THEN 'yes'
      ELSE 'no'
    END
  ) as is_tunnel,
  (
    CASE
      WHEN bridge IS NOT NULL
        THEN 'yes'
      ELSE 'no'
    END
  ) as is_bridge
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  (
    highway IN ('motorway', 'motorway_link',
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
   OR
   railway = 'rail' OR
   aeroway = 'runway'
  )
