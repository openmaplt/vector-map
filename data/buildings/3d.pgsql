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
  levels,
  min_height,
  min_level,
  roof_shape,
  roof_height,
  roof_levels,
  roof_direction,
  roof_orientation,
  colour,
  roof_colour
FROM (
  SELECT
    b.osm_id,
    b.way,
    b.building,
    cast(substring(coalesce(b.height, b."building:height") from '^[0-9]+(?:[.][0-9]+)?') AS real) AS tag_height,
    cast(substring(b."building:levels" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS levels,
    cast(substring(b.min_height from '^[0-9]+(?:[.][0-9]+)?') AS real) AS min_height,
    cast(substring(b."building:min_level" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS min_level,
    b."roof:shape" AS roof_shape,
    cast(substring(b."roof:height" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS roof_height,
    cast(substring(b."roof:levels" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS roof_levels,
    b."roof:direction" AS roof_direction,
    b."roof:orientation" AS roof_orientation,
    b."building:colour" AS colour,
    b."roof:colour" AS roof_colour
  FROM
    planet_osm_polygon AS b
  WHERE
    b.way && !BBOX! AND
    st_centroid(b.way) && !BBOX! AND
    b.building IS NOT NULL AND
    NOT (
      b."building:part" IS NOT NULL AND
      b."building:part" <> 'no' AND
      EXISTS (
        SELECT 1
        FROM planet_osm_polygon AS o
        WHERE
          o.way && b.way AND
          o.building IS NOT NULL AND
          o.building <> 'no' AND
          o.osm_id <> b.osm_id AND
          st_contains(o.way, st_pointonsurface(b.way))
      )
    )
) AS q
