SELECT
  gid AS __id__,
  geom AS __geometry__,
  kind AS kind
FROM
  details_line
WHERE
  geom && !bbox! AND
  kind = 'cutline'
