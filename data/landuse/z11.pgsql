SELECT
  osm_id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
  (
    CASE
      WHEN landuse = 'meadow' or "natural" = 'heath'
        THEN 'meadow'
      WHEN landuse = 'railway'
        THEN 'industrial'
      WHEN landuse is not null
        THEN landuse
      WHEN "natural" = 'wetland' AND "wetland" = 'marsh'
        THEN 'marsh'
      WHEN "natural" = 'wetland' AND "wetland" = 'swamp'
        THEN 'swamp'
    END
  ) AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  (
    landuse IN ('residential', 'meadow', 'farmland', 'allotments', 'industrial', 'farmyard', 'industrial', 'railway') OR
   "natural" in ('wetland', 'heath')
  ) AND
  way_area >= 51200

UNION ALL

SELECT
  id,
  st_asmvtgeom(way,!BBOX!) AS geometry,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !BBOX! AND
  res = 10 AND
  way_area >= 51200
