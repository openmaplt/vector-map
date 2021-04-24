drop materialized view if exists poi_topo;
create materialized view poi_topo (
  id
 ,__type__
 ,name
 ,short_name
 ,amenity
 ,man_made
 ,"tower:type"
 ,tourism
 ,"attraction:type"
 ,access
 ,"generator:source"
 ,religion
 ,aeroway
 ,power
 ,landuse
 ,building
 ,voltage
 ,"natural"
 ,way
) as
  select
        osm_id
        ,'n' -- always node
        ,case when site_type = 'fortification' then replace(replace(replace(name, 'piliakalnis', 'plk.'), 'alkakalnis', 'alk.'), 'piliavietė', 'plv.')
              when site_type = 'tumulus' then replace(name, 'pilkapiai', 'plkp.')
              when historic = 'manor' then replace(replace(replace(replace(name, 'dvaro sodybos fragmentai', 'dvr. frg.'), 'dvaro sodyba', 'dvr.'), 'dvaras', 'dvr.'), 'dvaro fragmentai', 'dvr. frg.')
              else name
         end as name
        ,case when site_type = 'fortification' then replace(replace(replace(short_name, 'piliakalnis', 'plk.'), 'alkakalnis', 'alk.'), 'piliavietė', 'plv.')
              when site_type = 'tumulus' then replace(short_name, 'pilkapiai', 'plkp.')
              when historic = 'manor' then replace(replace(replace(replace(short_name, 'dvaro sodybos fragmentai', 'dvr. frg.'), 'dvaro sodyba', 'dvr.'), 'dvaras', 'dvr.'), 'dvaro fragmentai', 'dvr. frg.')
              else short_name
         end as short_name
        ,amenity
        ,man_made
        ,"tower:type"
        ,case when site_type = 'fortification' then 'hillfort'
              when site_type = 'tumulus' then 'tumulus'
              when historic = 'manor' then 'manor'
              else tourism
         end as tourism
        ,"attraction:type"
        ,access
        ,"generator:source"
        ,religion
        ,aeroway
        ,power
        ,landuse
        ,building
        ,voltage
        ,"natural"
        ,way
    from planet_osm_point
   where aeroway in ('aerodrome', 'airstrip', 'helipad')
      or amenity = 'place_of_worship'
      or man_made in ('chimney', 'windmill', 'watermill', 'tower', 'communications_tower', 'lighthouse', 'water_tower', 'mast')
      or amenity = 'fuel'
      or power = 'substation'
      or (power = 'generator' and "generator:source" in ('hydro', 'wind'))
      or tourism = 'camp_site'
      or site_type in ('fortification', 'tumulus')
      or historic = 'manor'
      or "natural" = 'spring'
  union
  select
        ABS(osm_id)
        ,CASE WHEN osm_id < 0 THEN 'r' ELSE 'w' END  -- r relation, w way
        ,case when historic = 'manor' then replace(replace(replace(replace(name, 'dvaro sodybos fragmentai', 'dvr. frg.'), 'dvaro sodyba', 'dvr.'), 'dvaras', 'dvr.'), 'dvaro fragmentai', 'dvr. frg.')
              else name
         end as name
        ,case when historic = 'manor' then replace(replace(replace(replace(short_name, 'dvaro sodybos fragmentai', 'dvr. frg.'), 'dvaro sodyba', 'dvr.'), 'dvaras', 'dvr.'), 'dvaro fragmentai', 'dvr. frg.')
              else short_name
         end as short_name
        ,amenity
        ,man_made
        ,"tower:type"
        ,case when historic = 'manor' then 'manor'
              else tourism
         end as tourism
        ,null --"attraction:type"
        ,access
        ,"generator:source"
        ,religion
        ,aeroway
        ,power
        ,landuse
        ,building
        ,voltage
        ,"natural"
        ,st_centroid(way)
    from planet_osm_polygon
   where aeroway in ('aerodrome', 'airstrip', 'helipad')
      or amenity = 'place_of_worship'
      or man_made in ('chimney', 'windmill', 'watermill', 'tower', 'communications_tower', 'lighthouse', 'water_tower', 'mast')
      or amenity = 'fuel'
      or landuse = 'quarry'
      or power = 'substation'
      or (power = 'generator' and "generator:source" in ('hydro', 'wind'))
      or tourism = 'camp_site'
      or historic = 'manor';
