SELECT
  osm_id,
  way AS __geometry__,
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
  way && !bbox! AND
  (man_made = 'cutline' OR
   "natural" = 'cliff')

UNION ALL

SELECT
  osm_id,
  way,
  leisure
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  leisure = 'stadium'
