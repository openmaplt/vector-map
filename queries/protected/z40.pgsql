SELECT
  id AS __id__,
  way AS __geometry__,
  'national_park' AS kind,
  name
FROM
  gen_protected
WHERE
  way && !bbox! AND
  res = 40
