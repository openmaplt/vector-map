SELECT
  max(osm_id) AS gid,
  ST_AsMVTGeom(ST_LineMerge(ST_Collect(way)),!BBOX!) AS geom,
  route AS kind,
  network,
  name,
  distance
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  route IN ('bicycle', 'mtb')
GROUP BY
  route, network, name, distance
