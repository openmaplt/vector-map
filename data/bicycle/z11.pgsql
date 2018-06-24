SELECT
  max(osm_id) AS gid,
  ST_AsBinary(ST_LineMerge(ST_Collect(way))) AS geom,
  route AS kind,
  network,
  name,
  distance
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  route IN ('bicycle')
GROUP BY
  route, network, name, distance
