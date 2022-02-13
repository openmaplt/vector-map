SELECT
  row_number() over() AS gid,
  st_asmvtgeom(st_linemerge(st_collect(way)),!BBOX!) AS geom,
  case when highway = 'living_street' then coalesce(maxspeed, '20') else maxspeed end as maxspeed,
  "maxspeed:forward" as forward,
  "maxspeed:backward" as backward
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
               'service',
               'track')
  ) AND
  (maxspeed is not null or
   "maxspeed:forward" is not null or
   "maxspeed:backward" is not null or
   highway = 'living_street'
  )
GROUP BY "maxspeed:forward", "maxspeed:backward", maxspeed, highway
