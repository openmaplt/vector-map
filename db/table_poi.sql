create materialized view poi (
  name
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
 ,way
) as
  select name
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
        ,way
    from planet_osm_point
   where amenity is not null
      or shop is not null
      or real_ale is not null
      or tourism is not null
      or historic is not null
      or office is not null
  union
  select name
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
        ,st_centroid(way)
    from planet_osm_polygon
   where amenity is not null
      or shop is not null
      or real_ale is not null
      or tourism is not null
      or historic is not null
      or office is not null;
