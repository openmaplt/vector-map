SELECT
  row_number() over() AS gid,
  st_asmvtgeom(st_linemerge(st_collect(way)),!BBOX!) AS geom,
  (
    CASE
      WHEN highway IS NOT NULL
        THEN highway
      WHEN railway IS NOT NULL
        THEN coalesce(service, railway)
      WHEN aeroway IS NOT NULL
        THEN aeroway
    END
  ) AS kind,
  CASE WHEN surface in ('paved', 'asphalt', 'paving_stones') THEN 'paved'
       ELSE 'unpaved'
  END AS surface,
  CASE WHEN highway = 'motorway' THEN 1
       WHEN highway = 'trunk' THEN 2
       WHEN highway = 'primary' THEN 3
       WHEN highway = 'secondary' THEN 4
       WHEN highway = 'tertiary' THEN 5
       ELSE 6
  END AS priority,
  name,
  ref,
  CASE WHEN highway = 'track' and tracktype is null THEN 'grade3'
       WHEN highway = 'track' THEN tracktype
       ELSE null
  END AS tracktype,
  length(ref) AS ref_length,
  (
    CASE
      WHEN tunnel IS NOT NULL
        THEN 'yes'
      ELSE null
    END
  ) as is_tunnel,
  (
    CASE
      WHEN bridge IS NOT NULL
        THEN 'yes'
      ELSE null
    END
  ) as is_bridge,
  coalesce(oneway, 'no') AS oneway,
  layer
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  (
    highway IN ('motorway', 'motorway_link',
               'trunk', 'trunk_link',
               'primary','primary_link',
               'secondary', 'secondary_link',
               'tertiary', 'tertiary_link',
               'unclassified',
               'residential',
               'living_street',
               'proposed',
               'construction',
               'pedestrian',
               'service',
               'track',
               'footway',
               'cycleway',
               'steps',
               'path')
   OR
   railway = 'rail' OR
   aeroway IN ('runway', 'taxiway', 'parking_position')
  )
GROUP BY kind, surface, name, priority, ref, is_tunnel, is_bridge, oneway, highway, tracktype, layer
ORDER BY priority
