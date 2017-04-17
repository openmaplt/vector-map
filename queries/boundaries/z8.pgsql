SELECT
  way AS __geometry__,
  admin_level,
  (
    CASE
      WHEN admin_level = '2'
        THEN 'country'
      WHEN admin_level = '4'
        THEN 'region'
    END
  )   AS kind
FROM
  planet_osm_polygon
WHERE
  boundary IN ('administrative') AND admin_level IN ('2', '4')
  OR boundary = 'protected_area'