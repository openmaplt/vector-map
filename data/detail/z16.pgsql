SELECT
  osm_id AS gid,
  ST_AsBinary(way) AS geom,
  (
    CASE
      WHEN man_made is not null
        THEN man_made
      WHEN "natural" is not null
        THEN "natural"
    END
  ) AS kind
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  (man_made = 'cutline' OR
   "natural" = 'cliff')

UNION ALL

SELECT
  osm_id,
  ST_AsBinary(way),
  leisure AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  leisure = 'stadium'

