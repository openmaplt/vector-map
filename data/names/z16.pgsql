SELECT
  osm_id AS gid,
  ST_AsBinary(ST_PointOnSurface(way)) AS geom,
  (
    CASE
      WHEN landuse = 'cemetery'
        THEN 'cemetery'
      WHEN "natural" = 'water'
        THEN 'water'
      WHEN landuse = 'reservoir'
        THEN 'lake'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  (
    landuse IN ('cemetery', 'reservoir') OR
    "natural" IN ('water')
  ) AND
  name is not null
