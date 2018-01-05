SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  (
    CASE
      WHEN highway IS NOT NULL
        THEN highway
      WHEN railway IS NOT NULL
        THEN coalesce(service, railway)
    END
  ) AS kind,
  CASE WHEN highway = 'motorway' THEN 1
       WHEN highway = 'trunk' THEN 2
       WHEN highway = 'primary' THEN 3
       WHEN highway = 'secondary' THEN 4
       WHEN highway = 'tertiary' THEN 5
       ELSE 6
  END AS priority,
  name,
  ref,
  length(ref) AS ref_length
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
               'pedestrian')
   OR
   (railway = 'rail' AND service IS NULL)
  )
GROUP BY kind, name, priority, ref
ORDER BY priority
