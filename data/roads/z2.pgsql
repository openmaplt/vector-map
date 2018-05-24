SELECT
  r.__geometry__
 ,r.kind
 ,r.priority
 ,r.name
 ,r.ref
 ,r.ref_length
FROM
(SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  highway AS kind,
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
  )
GROUP BY kind, name, priority, ref

UNION ALL

SELECT
  way AS __geometry__,
  'rail' AS kind,
  7 AS priority,
  null AS name,
  null AS ref,
  null AS ref_length
FROM
  gen_ways
WHERE
  way && !bbox! AND
  type = 'rail'
) AS r

ORDER BY r.priority
