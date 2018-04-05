SELECT
  way AS __geometry__,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !bbox! AND
  res = 150 AND
  way_area >= 5000000
