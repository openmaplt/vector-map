SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
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
  ref
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  (
    highway IN ('motorway', 'motorway_link',
               'trunk', 'trunk_link',
               'primary', 'primary_link',
               'secondary', 'secondary_link',
               'tertiary', 'tertiary_link',
               'unclassified',
               'living_street',
               'residential',
               'pedestrian',
               'track')
   OR
   (railway = 'rail' AND service IS NULL)
   OR
   aeroway IN ('runway', 'taxiway', 'parking_position')
  )
GROUP BY
  (
    CASE
      WHEN highway IS NOT NULL
        THEN highway
      WHEN railway IS NOT NULL
        THEN coalesce(service, railway)
      WHEN aeroway IS NOT NULL
        THEN aeroway
    END
  ),
  name,
  ref
