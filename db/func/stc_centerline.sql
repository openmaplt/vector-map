create or replace function stc_centerline(p_way geometry, p_size integer) returns geometry as $$
declare
  sizex integer;
  sizey integer;
  f12 bigint := p_size;
  i integer := 0;
  j integer := 0;
  cx integer;
  cy integer;
  x1 float;
  x2 float;
  y1 float;
  y2 float;
  bbox geometry;
  gen geometry;
  g geometry;
  temp geometry;
  ga geometry[];
  c int[][] := array_fill(0, array[1300,1100]);
  cc int[][];
  t text;
  k text;
  added boolean;
  centx integer;
  centy integer;
  dist float;
  f1x integer;
  f1y integer;
  f2x integer;
  f2y integer;
begin
  gen = st_buffer(st_buffer(p_way, p_size/1.9), -p_size/2);
  bbox = st_envelope(gen);
  sizex := ceil((st_xmax(bbox) - st_xmin(bbox)) / f12);
  sizey := ceil((st_ymax(bbox) - st_ymin(bbox)) / f12);
  if sizex > 1300 then
    raise 'sizex % > 1300', sizex;
  elseif sizey > 1100 then
    raise 'sizey % > 1100', sizey;
  end if;
  
  -- Create initial matrix of cells with value 10000 when cell
  -- is inside polygon and 0, when cell is outside of polygon.
  if st_numgeometries(gen) = 1 then
    temp = st_exteriorring(gen);
  else
    temp = st_difference(st_buffer(st_envelope(gen), 10, 'join=mitre'), gen);
  end if;
  i = 0;
  delete from car_polygon;
  for cx in 1..sizex loop
    for cy in 1..sizey loop
      x2 := st_xmin(bbox) + f12 * cx;
      x1 := x2 - f12;
      y1 := st_ymax(bbox) - f12 * cy;
      y2 := y1 + f12;
      g := st_geomfromtext('POLYGON((' || x1 || ' ' || y1 || ', ' ||
                                    x2 || ' ' || y1 || ', ' ||
                                    x2 || ' ' || y2 || ', ' ||
                                    x1 || ' ' || y2 || ', ' ||
                                    x1 || ' ' || y1 ||
                                    '))', 3857);
      if st_covers(gen, g) then
        insert into car_polygon values (i, cx, cy, null, null, g);
        c[cx][cy] = st_distance(g, temp);
        if c[cx][cy] > i then
          i = c[cx][cy];
          centx = cx;
          centy = cy;
        end if;
        j = j + 1;
      end if;
    end loop;
  end loop;
  if i = 0 then
    return null;
  end if;
  raise notice 'Furtherst point %', i;

  -- For debug purposes:
  -- 1. Update gemetry table
  -- 2. Output value to stdout
  /*for cy in 1..sizey loop
    t := '';
    for cx in 1..sizex loop
      t := t || c[cx][cy];
      if c[cx][cy] > 0 then
        update car_polygon set s = c[cx][cy] where x = cx and y = cy;
      end if;
    end loop;
    --raise notice '%', t;
  end loop;*/

  -- Mark all cells of polygon part with center position with -1
  -- (Not connected parts will be left with other values)
  cc := c;
  cc[centx][centy] := -1;
  loop
    added := false;
    for cx in 1..sizex loop -- NOTE: Rules below should get out of bounds, but they don't...
      for cy in 1..sizey loop
        if cc[cx][cy] > 0 and
          (
            cc[cx+1][cy]   = -1 or
            cc[cx+1][cy+1] = -1 or
            cc[cx][cy+1]   = -1 or
            cc[cx-1][cy+1] = -1 or
            cc[cx-1][cy]   = -1 or
            cc[cx-1][cy-1] = -1 or
            cc[cx][cy-1]   = -1 or
            cc[cx+1][cy-1] = -1
          )
        then
          cc[cx][cy] := -1;
          added := true;
        end if;
      end loop;
    end loop;
    exit when not added;
  end loop;

  -- Output matrix for debug purposes
  for cy in 1..sizey loop
    t := '';
    for cx in 1..sizex loop
      if cc[cx][cy] = 0 then
        t := t || '.';
      elsif cc[cx][cy] = -1 then
        t := t || 'O';
      else
        t := t || 'x';
      end if;
    end loop;
    raise notice '%', t;
  end loop;

  -- Find point which is furthers from "center" point found above
  dist := 0;
  for cx in 2..sizex loop
    for cy in 2..sizey loop
      if cc[cx][cy] = -1 then
        if (@(cx-centx))^2 + (@(cy-centy))^2 > dist then
          dist := (@(cx-centx))^2 + (@(cy-centy))^2;
          f1x := cx;
          f1y := cy;
        end if;
      end if;
    end loop;
  end loop;
  if f1x is null then
    -- Nerastas pirmas tolimiausias taškas, matyt per dideli stačiakampiai
    return null;
  end if;
  raise notice 'First furtherest point % %', f1x, f1y;

  -- Find point, which is furthest from the "first" furthers point found above
  dist := 0;
  for cx in 2..sizex loop
    for cy in 2..sizey loop
      if cc[cx][cy] = -1 then
        if (@(cx-f1x))^2 + (@(cy-f1y))^2 > dist then
          dist := (@(cx-f1x))^2 + (@(cy-f1y))^2;
          f2x := cx;
          f2y := cy;
        end if;
      end if;
    end loop;
  end loop;
  raise notice 'Second furtherest point % %', f2x, f2y;

  cc[f1x][f1y] := 1;
  i := 1;
  loop
    -- Find largest wave neighbour
    j := 0;
    for cx in 1..sizex loop
      for cy in 1..sizey loop
        if cc[cx][cy] = -1 and
          (
            cc[cx+1][cy]   = i or
            cc[cx+1][cy+1] = i or
            cc[cx][cy+1]   = i or
            cc[cx-1][cy+1] = i or
            cc[cx-1][cy]   = i or
            cc[cx-1][cy-1] = i or
            cc[cx][cy-1]   = i or
            cc[cx+1][cy-1] = i
          )
        then
          if c[cx][cy] > j then
            j := c[cx][cy];
          end if;
        end if;
      end loop;
    end loop;
    if j = 0 then
      i = i - 1;
      if i = 0 then
        raise notice 'WARNING: Wave failed to fill everything';
        return null;
      end if;
      continue;
    end if;

    -- proceed with wave
    for cx in 1..sizex loop
      for cy in 1..sizey loop
        if cc[cx][cy] = -1 and
          (
            cc[cx+1][cy]   = i or
            cc[cx+1][cy+1] = i or
            cc[cx][cy+1]   = i or
            cc[cx-1][cy+1] = i or
            cc[cx-1][cy]   = i or
            cc[cx-1][cy-1] = i or
            cc[cx][cy-1]   = i or
            cc[cx+1][cy-1] = i
          )
        then
          if c[cx][cy] = j then
            cc[cx][cy] := i + 1;
          /*else
            cc[cx][cy] := -2;*/
          end if;
        end if;
      end loop;
    end loop;
    i := i + 1;

/*raise notice 'i=%', i;
if i = 94 then
  for cy in 1..sizey loop
    t := '';
    for cx in 1..sizex loop
      if cc[cx][cy] = 0 then
        t := t || '..';
      elsif cc[cx][cy] > -1 then
        t := t || cc[cx][cy];
      else
        t := t || 'xx';
      end if;
      update car_polygon set w = cc[cx][cy] where x = cx and y = cy;
    end loop;
    raise notice '%', t;
  end loop;
  return null;
end if;*/

    exit when cc[f2x][f2y] > -1 /*or i > 90*/;
  end loop;

  for cy in 1..sizey loop
    t := '';
    for cx in 1..sizex loop
      if cc[cx][cy] = 0 then
        t := t || ' ';
      else
        t := t || cc[cx][cy];
      end if;
      --update car_polygon set w = cc[cx][cy] where x = cx and y = cy;
      if cc[cx][cy] < 1 then
        cc[cx][cy] = 10000;
      end if;
    end loop;
    --raise notice '%', t;
  end loop;

  -- Construct center line
  t := 'LINESTRING(';
  select st_x(st_centroid(way)) || ' ' ||
         st_y(st_centroid(way))
    into k
    from car_polygon where x = f2x and y = f2y;
  t := t || k;
  --raise notice 'center line point %', t;
  cx = f2x;
  cy = f2y;
  j = 0;
  while i > 1 loop
    --i := i - 1;

    if cc[cx+1][cy  ] < i then i = cc[cx+1][cy  ]; end if;
    if cc[cx+1][cy+1] < i then i = cc[cx+1][cy+1]; end if;
    if cc[cx  ][cy+1] < i then i = cc[cx  ][cy+1]; end if;
    if cc[cx-1][cy+1] < i then i = cc[cx-1][cy+1]; end if;
    if cc[cx-1][cy  ] < i then i = cc[cx-1][cy  ]; end if;
    if cc[cx-1][cy-1] < i then i = cc[cx-1][cy-1]; end if;
    if cc[cx  ][cy-1] < i then i = cc[cx  ][cy-1]; end if;
    if cc[cx+1][cy-1] < i then i = cc[cx+1][cy-1]; end if;

    if cc[cx+1][cy]   = i then
      cx := cx + 1;
    elsif cc[cx+1][cy+1] = i then
      cx := cx + 1;
      cy := cy + 1;
    elsif cc[cx][cy+1]   = i then
      cy := cy + 1;
    elsif cc[cx-1][cy+1] = i then
      cx := cx - 1;
      cy := cy + 1;
    elsif cc[cx-1][cy]   = i then
      cx := cx - 1;
    elsif cc[cx-1][cy-1] = i then
      cx := cx - 1;
      cy := cy - 1;
    elsif cc[cx][cy-1]   = i then
      cy := cy - 1;
    elsif cc[cx+1][cy-1] = i then
      cx := cx + 1;
      cy := cy - 1;
    else
      raise 'NO FURTHER STEP FOUND!';
      return null;
    end if;
    select st_x(st_centroid(way)) || ' ' ||
           st_y(st_centroid(way))
      into k
      from car_polygon where x = cx and y = cy;
    t := t || ', ' || k;
    j = j + 1;
    --raise notice 'center line point %', k;
  end loop;
  t := t || ')';
  --raise notice 'final line %', t;

  g = st_geomfromtext(t, 3857);
  i = 1;
  temp = st_simplifyvw(st_chaikinsmoothing(g, 2), f12*f12*i);
  while st_covers(gen, st_buffer(temp, p_size/2)) and i < 5 loop
    raise notice 'smoothing level %', i;
    g = temp;
    i = i + 1;
    temp = st_simplifyvw(st_chaikinsmoothing(g, 2), f12*f12*i);
  end loop;
  return st_chaikinsmoothing(g, 2);
end$$ language plpgsql;
