SELECT
  osm_id AS gid,
  st_asmvtgeom(st_pointonsurface(way),!BBOX!) AS geom,
  name,
  admin_level,
  (
    CASE
      WHEN admin_level = '4'
        THEN 'region'
      WHEN admin_level = '5'
        THEN 'municipality'
      WHEN admin_level = '6'
        THEN 'county'
      WHEN admin_level = '8'
        THEN 'locality'
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  boundary = 'administrative' AND
  admin_level IN ('4', '5', '6', '8')