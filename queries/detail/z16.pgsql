SELECT
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
