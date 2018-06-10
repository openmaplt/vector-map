SELECT
  row_number() over() AS gid,
  st_asbinary(r.geom) AS geom,
  r.kind,
  r.priority,
  r.ref,
  r.ref_length
FROM
(SELECT
  st_linemerge(st_collect(way)) AS geom,
  highway AS kind,
  6 AS priority,
  ref,
  length(ref) AS ref_length
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  (
    highway IN ('secondary',
                'tertiary',
                'unclassified')
  )
GROUP BY kind, priority, ref

UNION ALL

SELECT
  st_linemerge(st_collect(way)) AS geom,
  type AS kind,
  CASE WHEN type = 'motorway' THEN 1
       WHEN type = 'trunk' THEN 2
       WHEN type = 'primary' THEN 3
       ELSE 6
  END AS priority,
  subtype AS ref,
  length(subtype) AS ref_length
FROM
  gen_ways
WHERE
  way && !BBOX! AND
  type != 'rail'
GROUP BY kind, priority, ref

UNION ALL

SELECT
  way AS geom,
  'rail' AS kind,
  7 AS priority,
  null as ref,
  null ref_length
FROM
  gen_ways
WHERE
  way && !BBOX! AND
  type = 'rail'
) AS r
ORDER BY r.priority
