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
            WHEN whitewater = 'dam;put_in'
              THEN 'dam_inout'
            WHEN whitewater = 'bridge;dam;put_in'
              THEN 'bridge_dam_inout'
            WHEN whitewater = 'bridge:put_in'
              THEN 'bridge_inout'
            WHEN whitewater = 'bridge:hazard'
              THEN 'bridge_warning'
            WHEN "waterway:milestone" is not null
              THEN 'milestone'
            ELSE whitewater
            END
         )
        ,way
    from planet_osm_point
   where whitewater is not null
      or "waterway:milestone" is not null;
