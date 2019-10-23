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
      WHEN "natural" = 'scrub'
        THEN 'scrub'
      WHEN aeroway is not null
        THEN aeroway
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  (
    landuse IN ('residential', 'commercial', 'industrial', 'meadow', 'farmland', 'allotments', 'cemetery', 'garages', 'orchard', 'farmyard', 'retail', 'railway', 'quarry') OR
   "natural" in ('wetland', 'beach', 'sand', 'scrub', 'heath') OR
   aeroway = 'runway'
  ) AND
  way_area >= 12800

UNION ALL

SELECT
  id,
  st_asbinary(way),
  round(st_area(way)/1000) AS area,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !BBOX! AND
  res = 10 AND
  way_area >= 12800
