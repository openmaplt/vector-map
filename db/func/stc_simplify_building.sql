create or replace function stc_simplify_building(r geometry, t integer, mi integer default 100, d boolean default false) returns geometry as $$
/*********************************************************************
* Simplify building
*********************************************************************/
declare
tp text := st_geometrytype(r);
n geometry;
e geometry;
g geometry[];
i integer;
j integer;
m1 text;
m2 text;
m3 text;
begin
  --raise notice 'Geometry type %, mi=%', tp, mi;
  if tp = 'ST_LineString' then
    return stc_simplify_building_line(stc_simplify_turbo(r), t, mi, d);
  elseif tp = 'ST_Polygon' then
    n := stc_simplify_building(st_exteriorring(r), t, mi, d);
    j := 0;
    for i in 1..st_numinteriorrings(r) loop
      --raise notice 'interior % % %', i, st_area(st_makepolygon(st_interiorringn(r, i))), st_numpoints(st_interiorringn(r, i));
      e = st_interiorringn(r, i);
      if st_area(st_makepolygon(e)) > t ^ 2 then
        e = stc_simplify_building(st_interiorringn(r, i), t, mi, d);
        if st_area(st_makepolygon(e)) > t ^ 2 then
          j := j + 1;
          g[j] = e;
        end if;
      end if;
    end loop;
    if j = 0 then
      return st_makepolygon(n);
    else
      return st_makepolygon(n, g);
    end if;
  elseif tp = 'ST_MultiPolygon' then
    if st_numgeometries(r) = 1 then
      return st_multi(stc_simplify_building(st_geometryn(r, 1), t, mi, d));
    else
      n = st_multi(st_union(st_buffer(st_buffer(r, t, 'join=mitre'), -t, 'join=mitre'), r));
      if st_numgeometries(n) = st_numgeometries(r) then
        n = r;
      end if;
      g := null;
      for i in 1..st_numgeometries(n) loop
        if st_area(st_geometryn(n, i)) > 100 then
          g[i] := stc_simplify_building(st_geometryn(n, i), t, mi, d);
        end if;
      end loop;
      return st_multi(st_union(g));
    end if;
  else
    raise notice 'ERROR: Unknown geometry type';
    return r;
  end if;
exception when others then
  get stacked diagnostics m1 = message_text,
                          m2 = pg_exception_detail,
                          m3 = pg_exception_hint;
  raise notice 'EXCEPTION OCCURED: % % %', m1, m2, m3;
  return r;
end
$$ language plpgsql;
