drop materialized view if exists poi_river;
create materialized view poi_river (
  id
 ,name
 ,kind
 ,way
) as
  select osm_id
        ,coalesce(distance, "waterway:milestone", name)
        ,(
          CASE
            WHEN whitewater in ('put_in;egress', 'egress', 'put_in')
              THEN 'inout'
            WHEN whitewater = 'hazard'
              THEN 'warning'
            WHEN whitewater = 'dam;put_in'
              THEN 'dam_inout'
            WHEN whitewater = 'bridge;dam;put_in'
              THEN 'bridge_dam_inout'
            WHEN whitewater in ('bridge;put_in', 'bridge;egress', 'bridge;egress;put_in', 'bridge;put_in;egress')
              THEN 'bridge_inout'
            WHEN whitewater in ('put_in;bridge', 'egress;bridge', 'egress;put_in;bridge', 'put_in;egress;bridge')
              THEN 'inout_bridge'
            WHEN whitewater = 'egress;put_in;bridge;hazard'
              THEN 'inout_bridge_hazard'
            WHEN whitewater = 'bridge;hazard'
              THEN 'bridge_warning'
            WHEN whitewater = 'bridge'
              THEN 'bridge'
            WHEN whitewater = 'dam'
              THEN 'dam2'
            WHEN "waterway:milestone" is not null
              THEN 'milestone'
            WHEN waterway = 'milestone'
              THEN 'milestone'
            ELSE whitewater
            END
         )
        ,way
    from planet_osm_point
   where whitewater is not null
      or "waterway:milestone" is not null
      or waterway = 'milestone';
