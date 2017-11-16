SELECT
  st_PointOnSurface(way) AS __geometry__,
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
  way && !bbox! AND
  (
    landuse IN ('cemetery', 'reservoir') OR
    "natural" IN ('water')
  ) AND
  name is not null
