SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  type AS kind,
  subtype AS ref,
  length(subtype) AS ref_length
FROM
  gen_ways
WHERE
  way && !bbox! AND
  type != 'rail'
GROUP BY type, subtype
