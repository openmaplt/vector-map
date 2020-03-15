do $$
declare
  c record;
  cc record;
  i integer;
  t text;
  s integer := 1;
begin
  delete from upiu_baseinai_plot;
  for c in (select p.osm_id, p.way, b.basin, p.name
              from planet_osm_polygon p
                  ,upiu_baseinai b
             where (st_intersects(p.way, b.way) or (st_touches(p.way, b.way)))
               and (p."natural" = 'water' or landuse = 'reservoir')) loop
    raise notice 'Pridedame %', c.name;
    insert into upiu_baseinai_plot(id, basin, way)
      values (c.osm_id, c.basin, st_multi(c.way));
  end loop;
end;
$$;
