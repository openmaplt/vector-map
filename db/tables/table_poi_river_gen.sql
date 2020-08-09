drop materialized view if exists poi_river_gen;
create materialized view poi_river_gen (
  id
 ,name
 ,kind
 ,way
) as
SELECT cid
      ,min(distance) distance
      ,CASE array_to_string(array_agg(whitewater order by distance desc),';')
        WHEN '' THEN 'milestone'
        WHEN 'put_in;egress;bridge' THEN 'inout_bridge'
        WHEN 'bridge;egress' THEN 'bridge_inout'
        WHEN 'bridge;put_in;egress' THEN 'bridge_inout'
        WHEN 'put_in;egress' THEN 'inout'
        ELSE array_to_string(array_agg(whitewater order by distance desc),';')
       END AS kind
      ,ST_Centroid(ST_Collect(way)) AS geom
FROM (
    SELECT osm_id
          ,whitewater
          ,cast(coalesce("waterway:milestone", distance) as float) distance
          ,ST_ClusterDBSCAN(way, eps := 100, minpoints := 1) over () AS cid
          ,way
    FROM planet_osm_point
    WHERE (whitewater is not null
       or waterway = 'milestone')
      and (distance is not null or "waterway:milestone" is not null)
    ORDER BY 3 desc) sq
GROUP BY cid;
