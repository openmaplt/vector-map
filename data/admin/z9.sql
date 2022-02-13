SELECT
  osm_id AS gid,
  st_asmvtgeom(st_union(way),!BBOX!) AS geom,
  admin_level,
  (
    CASE
      WHEN admin_level = '2'
        THEN 'country'
      WHEN admin_level = '4'
        THEN 'region'
      WHEN admin_level = '5'
        THEN 'municipality'
      WHEN admin_level = '6'
        THEN 'county'
    END
  ) AS kind
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  boundary = 'administrative' AND
  admin_level IN ('2', '4', '5', '6')
GROUP BY
  osm_id, admin_level
