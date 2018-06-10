SELECT
  row_number() over() AS gid,
  st_asbinary(st_linemerge(st_collect(way))) AS geom,
  type AS kind,
  subtype AS ref,
  length(subtype) AS ref_length
FROM
  gen_ways
WHERE
  way && !BBOX! AND
  type != 'rail'
GROUP BY type, subtype
