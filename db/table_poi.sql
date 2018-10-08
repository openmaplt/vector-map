drop materialized view if exists poi;
create materialized view poi (
  id
 ,__type__
 ,name
 ,amenity
 ,man_made
 ,"tower:type"
 ,tourism
 ,"attraction:type"
 ,access
 ,historic
 ,site_type
 ,shop
 ,information
 ,office
 ,official_name
 ,alt_name
 ,opening_hours
 ,website
 ,image
 ,"ref:lt:kpd"
 ,height
 ,wikipedia
 ,fee
 ,email
 ,phone
 ,"addr:city"
 ,"addr:street"
 ,"addr:housenumber"
 ,"addr:postcode"
 ,real_ale
 ,railway
 ,aeroway
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
        ,historic
        ,site_type
        ,shop
        ,information
        ,office
        ,official_name
        ,alt_name
        ,opening_hours
        ,website
        ,image
        ,"ref:lt:kpd"
        ,height
        ,wikipedia
        ,fee
        ,email
        ,phone
        ,"addr:city"
        ,"addr:street"
        ,"addr:housenumber"
        ,"addr:postcode"
        ,real_ale
        ,railway
        ,aeroway
        ,way
    from planet_osm_point
   where amenity is not null
      or shop is not null
      or real_ale is not null
      or tourism is not null
      or historic is not null
      or office is not null
      or railway = 'station'
      or aeroway in ('terminal', 'helipad', 'aerodrome')
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
        ,historic
        ,site_type
        ,shop
        ,information
        ,office
        ,official_name
        ,alt_name
        ,opening_hours
        ,website
        ,image
        ,"ref:lt:kpd"
        ,height
        ,wikipedia
        ,fee
        ,email
        ,phone
        ,"addr:city"
        ,"addr:street"
        ,"addr:housenumber"
        ,"addr:postcode"
        ,real_ale
        ,railway
        ,aeroway
        ,st_centroid(way)
    from planet_osm_polygon
   where amenity is not null
      or shop is not null
      or real_ale is not null
      or tourism is not null
      or historic is not null
      or office is not null
      or railway = 'station'
      or aeroway in ('terminal', 'helipad', 'aerodrome')
  union
  select
        ABS(osm_id)
        ,'w'
        ,name
        ,amenity
        ,man_made
        ,"tower:type"
        ,tourism
        ,null --"attraction:type"
        ,access
        ,historic
        ,site_type
        ,shop
        ,information
        ,office
        ,official_name
        ,alt_name
        ,opening_hours
        ,website
        ,image
        ,"ref:lt:kpd"
        ,height
        ,wikipedia
        ,fee
        ,email
        ,phone
        ,"addr:city"
        ,"addr:street"
        ,"addr:housenumber"
        ,"addr:postcode"
        ,real_ale
        ,null
        ,null
        ,st_centroid(way)
    from planet_osm_line
   where amenity is not null
      or shop is not null
      or real_ale is not null
      or tourism is not null
      or historic is not null
      or office is not null;
