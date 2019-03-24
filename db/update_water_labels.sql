delete from car_requests where osm_id not in (select osm_id
                                               from planet_osm_polygon
                                              where name is not null
                                                and ("natural" in ('water', 'bay') or landuse = 'reservoir'));
insert into car_requests (id, osm_id, type, dirty, last_update)
  select nextval('car_request_seq')
        ,osm_id
        ,'L'
        ,'Y'
        ,null
    from planet_osm_polygon
   where ("natural" in ('water', 'bay') or landuse = 'reservoir')
     and name is not null
     and osm_id not in (select osm_id from car_requests);
update car_requests r
   set dirty = 'Y'
 where exists (select 1 from planet_osm_polygon p where p.osm_id = r.osm_id and p.osm_timestamp > r.last_update - interval '1 hour');
select stc_process_centerlines();
