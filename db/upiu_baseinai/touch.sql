create or replace function touch(p_wave int) returns int as $$
declare
  c record;
  cc record;
  l_updated int := 0;
  l_u int := 0;
begin
  for c in (select way, basin, name
              from upiu_baseinai
             where wave = p_wave)
  loop
    for cc in (select id
                 from upiu_baseinai
                where st_touches(c.way, way)
                  and wave is null
                  and (basin is null or p_wave != 0)
                  and (coalesce(name, '!@#') != 'Nemunas' or c.name = 'Nemunas'))
    loop
      update upiu_baseinai set basin = c.basin, wave = p_wave + 1 where id = cc.id;
      get diagnostics l_u = row_count;
      l_updated := l_updated + l_u;
    end loop;
  end loop;
  raise notice 'banga % pakeitė %', p_wave, l_updated;
  return l_updated;
end
$$ language plpgsql;
