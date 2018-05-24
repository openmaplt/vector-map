SELECT
  osm_id AS __id__,
  way AS __geometry__,
  man_made AS kind
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  man_made = 'cutline'

UNION ALL

SELECT
  osm_id AS __id__,
  way AS __geometry__,
  leisure AS kind
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  leisure = 'stadium'
