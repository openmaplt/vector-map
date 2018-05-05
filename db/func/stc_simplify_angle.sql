create or replace function stc_simplify_angle(r geometry) returns geometry as $$
/*********************************************************************
*
*********************************************************************/
declare
i integer;
j integer;
prev geometry;
preva integer;
cura integer;
p geometry[];
begin
  for i in 1..st_numpoints(r) loop
    if i > 1 then
      cura := degrees(st_azimuth(prev, st_pointn(r, i)));
      --raise notice 'azimuth diff % at vertex %', cura - preva, i;
      if cura - preva between -3 and 3 then
        for j in i-1..st_numpoints(r) loop
          p[j] := st_pointn(r, j+1);
        end loop;
        return st_makeline(p);
      end if;
    else
      cura := 1000;
    end if;
    prev := st_pointn(r, i);
    p[i] := st_pointn(r, i);
    preva := cura;
  end loop;

  return r;
end
$$ language plpgsql;
