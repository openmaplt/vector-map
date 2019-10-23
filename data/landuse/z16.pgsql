SELECT
  osm_id AS gid,
  st_asbinary(way) AS geom,
  round(st_area(way)/1000) AS area,
  (
    CASE
      WHEN landuse = 'meadow' or "natural" = 'heath'
        THEN 'meadow'
      WHEN landuse = 'retail'
        THEN 'commercial'
      WHEN landuse = 'railway'
        THEN 'industrial'
      WHEN landuse is not null
        THEN landuse
      WHEN "natural" = 'wetland' AND "wetland" = 'marsh'
        THEN 'marsh'
      WHEN "natural" = 'wetland' AND "wetland" = 'swamp'
        THEN 'swamp'
      WHEN "natural" = 'wetland' AND "wetland" = 'reedbed'
        THEN 'reedbed'
      WHEN "natural" in ('beach', 'sand')
        THEN 'sand'
      WHEN "natural" is not null
        THEN "natural"
      WHEN leisure is not null
        THEN leisure
      WHEN aeroway is not null
        THEN aeroway
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  (
    landuse in ('forest', 'residential', 'commercial', 'industrial', 'meadow', 'farmland', 'allotments', 'cemetery', 'garages', 'orchard', 'farmyard', 'retail', 'railway', 'quarry')
    OR "natural" in ('wetland', 'sand', 'beach', 'scrub', 'heath')
    OR leisure = 'park'
    OR aeroway in ('apron', 'runway')
  )
