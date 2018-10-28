drop table if exists upiu_baseinai_tmp;
create table upiu_baseinai_tmp (id bigint, waterway text, name text, wikipedia text, key text, status text, way geometry);
create index upiu_baseinai_gix on upiu_baseinai_tmp using gist(way);
create index upiu_baseinai_name on upiu_baseinai_tmp(key);
do $$declare
l_remain   bigint;
l_id       bigint;
l_way      geometry;
l_key      text;
l_waterway text;
l_name     text;
l_wikipedia text;
changed    boolean;
updated    boolean;
c          record;
l_start    bigint;
l_end      bigint;
l_type     text;
i          integer;
cc         record;
begin
  raise notice 'START %', clock_timestamp();
  for cc in (select distinct waterway
               from planet_osm_line
              where waterway in ('river', 'stream')) loop
    raise notice 'processing %', cc.waterway;
    insert into upiu_baseinai_tmp
      select nextval('upiu_baseinai_seq'),
             waterway,
             coalesce("name:lt", name),
             wikipedia,
             waterway || coalesce(name, '!@#') || coalesce(wikipedia, '!@#') as key,
             'N' as status,
             way
        from planet_osm_line
       where waterway = cc.waterway;
    select count(1) into l_remain from upiu_baseinai_tmp where status = 'N';
    l_start = l_remain;
    while l_remain > 0 loop
      select id, way, key, waterway, name, wikipedia
        into l_id, l_way, l_key, l_waterway, l_name, l_wikipedia
        from upiu_baseinai_tmp
       where status = 'N'
       limit 1;
      changed = true;
      updated = false;
      update upiu_baseinai_tmp set status = 'M' where id = l_id;
      l_remain = l_remain - 1;
      while changed loop
        changed = false;
        for c in (select id, way
                    from upiu_baseinai_tmp
                   where status = 'N'
                     and (st_endpoint(way)   = st_endpoint(l_way)   or
                          st_endpoint(way)   = st_startpoint(l_way) or
                          st_startpoint(way) = st_endpoint(l_way)   or
                          st_startpoint(way) = st_endpoint(l_way))
                     and st_dwithin(way, l_way, 0)
                     and key = l_key
                   limit 1) loop
          changed = true;
          updated = true;
          l_way = st_linemerge(st_collect(l_way, c.way));
          delete from upiu_baseinai_tmp where id = c.id;
        end loop;
      end loop;
      if updated then
        l_type = st_geometrytype(l_way);
        if l_type = 'ST_LineString' then
          update upiu_baseinai_tmp set way = l_way where id = l_id;
        elseif l_type = 'ST_MultiLineString' then
          for i in 1..st_numgeometries(l_way) loop
            if i = 1 then
              update upiu_baseinai_tmp set way = st_geometryn(l_way, i), status = 'U' where id = l_id;
              l_remain = l_remain - 1;
            else
              insert into upiu_baseinai_tmp (id, waterway, name, wikipedia, way, status) values
                (nextval('upiu_baseinai_seq'), l_waterway, l_name, l_wikipedia, st_geometryn(l_way, i), 'U');
            end if;
          end loop;
        else
          raise 'Unknown geometry type %', l_type;
        end if;
      end if;
    end loop;
    select count(1) into l_end from upiu_baseinai_tmp;
    raise notice '% %->% (%)', cc.waterway, l_start, l_end, clock_timestamp();
    insert into upiu_baseinai
      select id, null, null, name, wikipedia, waterway, way from upiu_baseinai_tmp;
    delete from upiu_baseinai_tmp;
  end loop;
  raise notice 'END %', clock_timestamp();
end$$;
drop table upiu_baseinai_tmp;
