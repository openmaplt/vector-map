create or replace function stc_simplify_turbo(g geometry) returns geometry as $$
/***********************************************************************
* Performes an improved simplification. If first/last vertex of a line
* making a poligon is on the same line as 2nd and 1 before last node:
* (last-1)-------------(last/first)---------(2nd)
* st_simplify does not remove such last/first node
* simplify_turbo moves all nodes so that st_simplify could remove
* such excess vertex.
***********************************************************************/
declare
l geometry;
p geometry[];
i integer;
begin
  -- simplify given line
  l := st_simplify(g, 0.5);

  -- move vertexes up
  l := stc_move_up(l);

  -- simplify again
  l := st_simplify(l, 0.5);

  return l;
end
$$ language plpgsql;
