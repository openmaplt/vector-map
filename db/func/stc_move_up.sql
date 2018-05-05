create or replace function stc_move_up(g geometry) returns geometry as $$
/*******************************************************
* Move (rotate) all line points "up"
* point number 2 becomes point 1
* point number 3 becomes point 2
* etc.
* last point becomes point 1
* Used to move area of interest further away from
* line end (for simplification or altering/calculation)
*******************************************************/
declare
i integer;
p geometry[];
begin
  for i in 1..st_numpoints(g)-1 loop
    p[i+1] = st_pointn(g, i);
  end loop;
  p[1] := p[st_numpoints(g)];

  return st_makeline(p);
end
$$ language plpgsql;
