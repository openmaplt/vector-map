SELECT
  way AS __geometry__,
  'yes' AS kind,
  null AS name,
  null AS height
FROM
  gen_building
WHERE
  way && !bbox! /*AND
  way_area > 160*/
