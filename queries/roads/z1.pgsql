SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  highway AS kind,
  CASE WHEN highway = 'motorway' THEN 1
       WHEN highway = 'trunk' THEN 2
       WHEN highway = 'primary' THEN 3
  END AS priority,
  ref,
  length(ref) AS ref_length
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  highway IN ('motorway', 'trunk', 'primary')
GROUP BY highway, priority, ref
ORDER BY priority
