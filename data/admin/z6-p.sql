SELECT
  osm_id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
  admin_level,
  (
    CASE
      WHEN admin_level = '2'
        THEN 'country'
      WHEN admin_level = '4'
        THEN 'region'
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  boundary = 'administrative' AND
  admin_level in ('2', '4')
