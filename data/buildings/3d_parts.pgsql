SELECT
  gid,
  st_asmvtgeom(way, !BBOX!, 4096, 0, false) AS geom,
  parent_id AS building,
  kind,
  height,
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
    p.osm_id AS gid,
    p.way,
    p.building AS own_building,
    parent.osm_id AS parent_id,
    coalesce(parent.way, p.way) AS anchor,
    p."building:part" AS kind,
    cast(substring(coalesce(p.height, p."building:height") from '^[0-9]+(?:[.][0-9]+)?') AS real) AS height,
    cast(substring(p."building:levels" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS levels,
    cast(substring(p.min_height from '^[0-9]+(?:[.][0-9]+)?') AS real) AS min_height,
    cast(substring(p."building:min_level" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS min_level,
    p."roof:shape" AS roof_shape,
    cast(substring(p."roof:height" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS roof_height,
    cast(substring(p."roof:levels" from '^[0-9]+(?:[.][0-9]+)?') AS real) AS roof_levels,
    p."roof:direction" AS roof_direction,
    p."roof:orientation" AS roof_orientation,
    p."building:colour" AS colour,
    p."roof:colour" AS roof_colour
  FROM
    planet_osm_polygon AS p
    LEFT JOIN LATERAL (
      SELECT o.osm_id, o.way
      FROM planet_osm_polygon AS o
      WHERE
        o.way && p.way AND
        o.building IS NOT NULL AND
        o.building <> 'no' AND
        o.osm_id <> p.osm_id AND
        st_contains(o.way, st_pointonsurface(p.way))
      ORDER BY o.way_area
      LIMIT 1
    ) AS parent ON true
  WHERE
    p.way && st_expand(!BBOX!, 1000) AND
    p."building:part" IS NOT NULL AND
    p."building:part" <> 'no'
) AS q
WHERE
  st_centroid(anchor) && !BBOX! AND
  (parent_id IS NOT NULL OR own_building IS NULL)
