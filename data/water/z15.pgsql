SELECT
  max(osm_id) AS gid,
  st_asmvtgeom(st_union(way),!BBOX!) AS geom,
  (
    CASE
      WHEN "natural" = 'water'
        THEN 'water'
      WHEN landuse = 'basin'
        THEN 'basin'
      WHEN landuse = 'reservoir'
        THEN 'water'
      WHEN amenity = 'swimming_pool' OR leisure = 'swimming_pool'
        THEN 'swimming_pool'
    END
  ) AS kind,
  null AS name,
  null AS virtual
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  (
    "natural" = 'water' OR
    landuse IN ('basin', 'reservoir') OR
    amenity = 'swimming_pool' OR
    leisure = 'swimming_pool'
  ) AND
  way_area >= 200
GROUP BY
  kind
