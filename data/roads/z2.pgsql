SELECT
  row_number() over() AS gid,
  st_asbinary(r.geom) AS geom,
  r.kind,
  r.priority,
  r.name,
  r.ref,
  r.ref_length
FROM
(SELECT
  st_linemerge(st_collect(way)) AS geom,
  highway AS kind,
  CASE WHEN surface in ('paved', 'asphalt', 'paving_stones') THEN 'paved'
       ELSE 'unpaved'
  END AS surface,
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
  way && !BBOX! AND
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
GROUP BY kind, surface, name, priority, ref

UNION ALL

SELECT
  way AS geom,
  'rail' AS kind,
  'paved' AS surface,
  7 AS priority,
  null AS name,
  null AS ref,
  null AS ref_length
FROM
  gen_ways
WHERE
  way && !BBOX! AND
  type = 'rail'
) AS r

ORDER BY r.priority
