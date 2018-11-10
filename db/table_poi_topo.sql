drop materialized view if exists poi_topo;
create materialized view poi_topo (
  id
 ,__type__
 ,name
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
 ,way
) as
  select
        osm_id
        ,'n' -- always node
        ,name
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
        ,way
    from planet_osm_point
   where aeroway in ('aerodrome', 'helipad')
      or amenity = 'place_of_worship'
      or man_made in ('chimney', 'windmill', 'watermill', 'tower', 'communications_tower', 'lighthouse', 'water_tower', 'mast')
      or amenity = 'fuel'
      or power = 'substation'
      or (power = 'generator' and "generator:source" in ('hydro', 'wind'))
      or tourism = 'camp_site'
  union
  select
        ABS(osm_id)
        ,CASE WHEN osm_id < 0 THEN 'r' ELSE 'w' END  -- r relation, w way
        ,name
        ,amenity
        ,man_made
        ,"tower:type"
        ,tourism
        ,null --"attraction:type"
        ,access
        ,"generator:source"
        ,religion
        ,aeroway
        ,power
        ,landuse
        ,building
        ,voltage
        ,st_centroid(way)
    from planet_osm_polygon
   where aeroway in ('aerodrome', 'helipad')
      or amenity = 'place_of_worship'
      or man_made in ('chimney', 'windmill', 'watermill', 'tower', 'communications_tower', 'lighthouse', 'water_tower', 'mast')
      or amenity = 'fuel'
      or landuse = 'quary'
      or power = 'substation'
      or (power = 'generator' and "generator:source" in ('hydro', 'wind'))
      or tourism = 'camp_site';
