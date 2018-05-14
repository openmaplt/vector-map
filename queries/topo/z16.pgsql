SELECT
  id,
  id AS __id__,
  __type__,
  way AS __geometry__,
  name,
  (
    CASE
    WHEN aeroway = 'aerodrome'
      THEN 'airport'
    WHEN amenity = 'place_of_worship' and building = 'chapel'
      THEN 'chapel'
    WHEN man_made = 'chimnei'
      THEN 'chimney'
    WHEN man_made = 'tower'
      THEN 'tower'
    WHEN amenity = 'fuel'
      THEN 'fuel'
    WHEN aeroway = 'helipad'
      THEN 'helipad'
    WHEN landuse = 'quary'
      THEN 'quary'
    WHEN power = 'substation'
      THEN 'substation'
    WHEN man_made = 'windmill'
      THEN 'windmill'
    WHEN amenity = 'place_of_worship' and religion = 'christian'
      THEN 'worship_christian'
    WHEN amenity = 'place_of_worship' and religion != 'christian'
      THEN 'worship_other'
    END
  ) AS kind
FROM
  poi_topo
WHERE
  way && !bbox!
