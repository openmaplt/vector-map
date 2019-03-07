create or replace function stc_polygon_labels(p_id bigint, p_way geometry, p_zoom integer, p_size integer) returns boolean as $$
declare
  size integer := p_size;
  i integer := 0;
  j integer := 0;
  sizex integer;
  sizey integer;
  cx integer;
  cy integer;
  cx2 integer;
  cy2 integer;
  x1 float;
  x2 float;
  y1 float;
  y2 float;
  bbox geometry;
  gen geometry;
  g geometry;
  c int[][] := array_fill(0, array[600,500]);
  added boolean;
begin
  gen = st_buffer(st_buffer(p_way, p_size/2), -p_size/2);
  bbox = st_envelope(gen);
  size = size * 2;
  sizex := ceil((st_xmax(bbox) - st_xmin(bbox)) / size);
  sizey := ceil((st_ymax(bbox) - st_ymin(bbox)) / size);
  if sizex > 600 then
    raise 'sizex % > 600', sizex;
  elseif sizey > 500 then
    raise 'sizey % > 500', sizey;
  end if;

  delete from car_polygon;
  for cx in 1..sizex loop
    for cy in 1..sizey loop
      i := i + 1;
      x2 := st_xmin(bbox) + size * cx;
      x1 := x2 - size;
      y1 := st_ymax(bbox) - size * cy;
      y2 := y1 + size;
      g := st_geomfromtext('POLYGON((' || x1 || ' ' || y1 || ', ' ||
                                    x2 || ' ' || y1 || ', ' ||
                                    x2 || ' ' || y2 || ', ' ||
                                    x1 || ' ' || y2 || ', ' ||
                                    x1 || ' ' || y1 ||
                                    '))', 3857);
      if st_covers(gen, g) then
        insert into car_polygon values (i, cx, cy, null, null, g);
        c[cx][cy] := 1000;
        j = j + 1;
      end if;
    end loop;
  end loop;
  if j = 0 then return false; end if;
  loop
    added := false;
    for cy2 in 1..sizey loop
      for cx2 in 1..sizex loop
        if c[cx2][cy2] = 1000 then
          c[cx2][cy2] := 1;
          update car_polygon set s = 1 where x = cx2 and y = cy2;
          added := true;

    for i in 1..3 loop
    for cy in 1..sizey loop
      for cx in 1..sizex loop
        if c[cx][cy] = i then
          if c[cx+1][cy]   = 1000 then c[cx+1][cy]   = i + 1; end if;
          if c[cx+1][cy+1] = 1000 then c[cx+1][cy+1] = i + 1; end if;
          if c[cx][cy+1]   = 1000 then c[cx][cy+1]   = i + 1; end if;
          if c[cx-1][cy+1] = 1000 then c[cx-1][cy+1] = i + 1; end if;
          if c[cx-1][cy]   = 1000 then c[cx-1][cy]   = i + 1; end if;
          if c[cx-1][cy-1] = 1000 then c[cx-1][cy-1] = i + 1; end if;
          if c[cx][cy-1]   = 1000 then c[cx][cy-1]   = i + 1; end if;
          if c[cx+1][cy-1] = 1000 then c[cx+1][cy-1] = i + 1; end if;
        end if;
      end loop;
    end loop;
    end loop;

        end if;
      end loop;
    end loop;
    exit when not added;
  end loop;

  insert into car_labels 
    select 1, null /* osm_id */, '-', p_zoom, 28 /* font size */, 1 /* letter spacing */, st_centroid(way)
      from car_polygon
     where s = '1';

  return true;
end$$ language plpgsql;
