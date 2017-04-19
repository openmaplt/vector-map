SELECT
  way AS __geometry__,
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
  )   AS kind
FROM
  planet_osm_line
WHERE
  boundary IN ('administrative') AND admin_level IN ('2', '4', '6', '8')
  OR boundary = 'protected_area'