SELECT
  row_number() over() AS gid,
  st_asbinary(st_linemerge(st_collect(way))) AS geom,
  maxspeed,
  "maxspeed:forward" forward,
  "maxspeed:backward" backward
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  (
    highway IN ('motorway', 'motorway_link',
               'trunk', 'trunk_link',
               'primary', 'primary_link',
               'secondary', 'secondary_link',
               'tertiary', 'tertiary_link',
               'unclassified',
               'living_street',
               'residential')
   OR (highway = 'service' AND service = 'long_distance')
   OR (highway = 'track' AND coalesce(track, '!@#') != 'driveway')
  ) AND
  (maxspeed is not null or
   "maxspeed:forward" is not null or
   "maxspeed:backward" is not null
  )
GROUP BY maxspeed, "maxspeed:forward", "maxspeed:backward"
