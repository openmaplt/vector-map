SELECT
  osm_id AS gid,
  st_asmvtgeom(way, !BBOX!, 4096, 0, false) AS geom,
  building AS kind,
  coalesce(tag_height, levels * 3, 6) AS height,
  CASE
    WHEN tag_height IS NOT NULL THEN 'tag'
    WHEN levels IS NOT NULL THEN 'levels'
    ELSE 'default'
  END AS height_src,
  levels
FROM (
  SELECT
    osm_id,
    way,
    building,
    cast(substring(coalesce(height, "building:height") from '^[0-9]+(?:[.][0-9]+)?') AS real) AS tag_height,
    cast(substring("building:levels" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS levels
  FROM
    planet_osm_polygon
  WHERE
    way && !BBOX! AND
    st_centroid(way) && !BBOX! AND
    building IS NOT NULL
) AS b
