SELECT
  id AS gid,
  ST_AsBinary(way) AS geom,
  id,
  __type__,
  name,
  (
    CASE
    WHEN aeroway in ('aerodrome', 'airstrip')
      THEN 'airport'
    WHEN amenity = 'place_of_worship' and building = 'chapel'
      THEN 'chapel'
    WHEN man_made = 'chimney'
      THEN 'chimney'
    WHEN man_made = 'communications_tower'
      THEN 'communication_tower'
    WHEN man_made = 'tower' and "tower:type" in ('observation', 'communication')
      THEN 'light_tower'
    WHEN man_made = 'mast'
      THEN 'light_tower'
    WHEN man_made in ('tower', 'water_tower')
      THEN 'tower'
    WHEN man_made = 'lighthouse'
      THEN 'beacon'
    WHEN amenity = 'fuel'
      THEN 'fuel'
    WHEN aeroway = 'helipad'
      THEN 'helipad'
    WHEN landuse = 'quary'
      THEN 'quary'
    WHEN power = 'substation'
      THEN 'substation'
    WHEN power = 'generator' and "generator:source" = 'hydro'
      THEN 'hydro'
    WHEN power = 'generator' and "generator:source" = 'wind'
      THEN 'windpower'
    WHEN man_made = 'windmill'
      THEN 'windmill'
    WHEN amenity = 'place_of_worship' and religion = 'christian'
      THEN 'worship_christian'
    WHEN amenity = 'place_of_worship' and religion != 'christian'
      THEN 'worship_other'
    WHEN tourism = 'camp_site'
      THEN 'camp'
    WHEN tourism = 'hillfort'
      THEN 'hillfort'
    WHEN tourism = 'manor'
      THEN 'manor'
    END
  ) AS kind
FROM
  poi_topo
WHERE
  way && !BBOX!
ORDER BY
  CASE WHEN amenity = 'place_of_worship' THEN 1
       WHEN man_made = 'lighthouse' THEN 2
       ELSE 99
  END
