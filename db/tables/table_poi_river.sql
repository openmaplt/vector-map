drop materialized view if exists poi_river;
create materialized view poi_river (
  id
 ,name
 ,kind
 ,way
) as
  select osm_id
        ,coalesce("waterway:milestone", name)
        ,(
          CASE
            WHEN whitewater in ('put_in;egress', 'egress', 'put_in')
              THEN 'inout'
            WHEN whitewater = 'hazard'
              THEN 'warning'
            WHEN whitewater = 'hazard;put_in'
              THEN 'warning_inout'
            WHEN "waterway:milestone" is not null
              THEN 'milestone'
            END
         )
        ,way
    from planet_osm_point
   where whitewater is not null
      or "waterway:milestone" is not null;
