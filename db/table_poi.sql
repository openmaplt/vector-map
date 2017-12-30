drop table poi_test;

create table poi_test (
  name text
 ,amenity text
 ,man_made text
 ,"tower:type" text
 ,tourism text
 ,"attraction:type" text
 ,access text
 ,historic text
 ,site_type text
 ,shop text
 ,information text
 ,office text
 ,official_name text
 ,alt_name text
 ,opening_hours text
 ,website text
 ,image text
 ,"ref:lt:kpd" text
 ,height text
 ,wikipedia text
 ,fee text
 ,email text
 ,phone text
 ,"addr:city" text
 ,"addr:street" text
 ,"addr:housenumber" text
);

select addgeometrycolumn('poi_test', 'way', 3857, 'POINT', 2);

insert into poi_test
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

select count(1) from poi_test;

vacuum analyze;
