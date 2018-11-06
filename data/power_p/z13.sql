select osm_id as gid
      ,st_asbinary(way) as geom
  from planet_osm_point
 where way && !bbox!
   and power = 'tower'
