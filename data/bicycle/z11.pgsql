create or replace view t_bicycle_11 as
SELECT
  max(osm_id) AS id,
  st_asbinary(st_linemerge(st_collect(way))) AS geometry,
  route AS kind,
  network,
  name,
  distance
FROM
  planet_osm_line
WHERE
  route IN ('bicycle')
GROUP BY
  route, network, name, distance;
