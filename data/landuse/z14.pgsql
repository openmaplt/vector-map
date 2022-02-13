SELECT
  osm_id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
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
      WHEN "area:aeroway" is not null
        THEN "area:aeroway"
      WHEN amenity = 'grave_yard'
        THEN 'cemetery'
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  (
    landuse in ('residential', 'commercial', 'industrial', 'meadow', 'farmland', 'allotments', 'cemetery', 'garages', 'orchard', 'farmyard', 'retail', 'railway', 'quarry')
    OR "natural" in ('wetland', 'sand', 'beach', 'scrub', 'heath')
    OR aeroway in ('apron', 'runway')
    OR "area:aeroway" = 'runway'
    OR amenity = 'grave_yard'
  ) AND
  way_area >= 800

UNION ALL

SELECT
  id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
  round(st_area(way)/1000) AS area,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !BBOX! AND
  res = 10 AND
  way_area >= 800
