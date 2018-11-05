select osm_id as gid
      ,st_asbinary(way) as geom
      ,case when voltage = '110000' then '110'
            when voltage = '35000' then '35'
       end as voltage
  from planet_osm_line
 where way && !bbox!
   and power = 'line'
