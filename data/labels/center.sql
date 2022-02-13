select id as gid
      ,st_asmvtgeom(way,!BBOX!) as geom
      ,name
      ,size as font_size
      ,spacing as letter_spacing
  from car_centerline
 where way && !bbox!
   and ((zoom = !zoom!) or
        (!zoom! = 18 and zoom = 17))
