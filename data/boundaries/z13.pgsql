SELECT
  osm_id AS gid,
  st_asbinary(st_union(way)) AS geom,
  admin_level,
  (
    CASE
      WHEN admin_level = '2'
        THEN 'country'
      WHEN admin_level = '4'
        THEN 'region'
      WHEN admin_level = '6'
        THEN 'county'
      WHEN admin_level = '8'
        THEN 'locality'
    END
  ) AS kind
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  boundary = 'administrative' AND
  ((admin_level = '2' AND name = 'Lietuva') /*or admin_level IN ('4', '6', '8')*/) AND
  name not in ('Latgale', 'Kurzeme', 'Zemgale')
GROUP BY
  osm_id, admin_level
