create or replace function stc_remove_spike(r geometry) returns geometry as $$
/*********************************************************************
* Removes possible ONE internal spike:
* removes vertex, at which azimuth change is 180
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
      if (cura - preva between 170 and 190) or
         (cura - preva between -190 and -170) then
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
