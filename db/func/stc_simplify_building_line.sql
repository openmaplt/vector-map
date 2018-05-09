create or replace function stc_simplify_building_line(r geometry, t integer, l integer default 100, d boolean default false) returns geometry as $$
/*******************************************************************
* Simplify building line (exterior or interior ring).
* @g = line geometry (not polygon!)
* @t = tolerance
* @d = debug true|false
*******************************************************************/
declare
fg geometry;     -- final geometry
prev geometry;   -- previous geometry
smallest float;  -- length of smallest edge
sn integer;      -- position of second vertex of smallest edge
len float;       -- length of current vertex
i integer;
aze float;       -- azimuth of chosen (shortest) edge
azp float;       -- azimuth of shortest element + 1
azm float;       -- azimuth of shortest element - 1
intrusion boolean; -- true - intrusion, false - extrusion
lp float;        -- length of shortest element + 1
lm float;        -- length of shortest element - 1
ac integer;      -- azimuth change (between edge-1 and edge+1)
az float;        -- working azimuth (usage depending on case)
azc integer;     -- working azimuth change (usage depending on case)
l1 geometry;     -- first new point search line
l2 geometry;     -- second new point search line
np geometry;     -- new point (points will be moved to this position for simplification)
np2 geometry;    -- new point2 (for some calculations 2 new point positions are calculated)
ex geometry=ST_GeomFromText('LINESTRING EMPTY'); -- excluded edges
ig geometry;     -- initial iteration geometry
dg boolean = d;  -- debug (insert debug geomeries)
edge geometry;   -- shortest edge
ew geometry;     -- working edge (usage depending on case)
max integer = l;
begin
  fg = stc_simplify_angle(r);
  loop
    if max = 0 then
      return fg;
    else
      max = max - 1;
    end if;
    --raise notice 'remaining iterations %', max+1;
    ig = fg;

    if dg then delete from temp where id != 0; end if; -- debug
    -- Do not try to simplify geometry if it only has 4 vertexes
    if st_numpoints(fg) <= 5 then
      return fg;
    end if;
    if dg then insert into temp values (1, fg); end if; -- debug

    ------------------------------------
    -- Find shortest not excluded edge
    ------------------------------------
    smallest = 1000000;
    -- loop through all edges and find the smallest one
    for i in 1..st_numpoints(fg) loop
      if i > 1 then
        -- calculate length of line made of vertexes i-1 and i
        edge = st_makeline(prev, st_pointn(fg, i));
        len = st_length(edge);
        --raise notice 'length % = %', i, len; -- debug
        if len < smallest and len <= t then
          if not st_isempty(st_difference(edge, st_buffer(ex, 0.1))) then
            smallest = len;
            sn = i;
          --else
          --  raise notice 'edge in exclusion list';
          end if;
        end if;
      end if;
      prev = st_pointn(fg, i);
    end loop;
    edge = st_makeline(st_pointn(fg, sn-1), st_pointn(fg, sn));

    if smallest = 1000000 then
      -- there are no edges to be simplified
      return fg;
    else
      --raise notice 'smallest edge is % (%)', sn, smallest;
      if dg then insert into temp values (5, st_makeline(st_pointn(fg, sn - 1), st_pointn(fg, sn))); end if; -- debug
      -- if smallest edge is close to the end/start of the line - move all vertexes
      -- so that we could easily reach neighbouring elements
      -- TODO: modify "move_up" to be able to rotate vertexes not +1, but +/-n positions in one go
      if sn = 2 then
        fg = stc_move_up(fg);
        fg = stc_move_up(fg);
        sn = sn + 2;
      elseif sn = 3 then
        fg = stc_move_up(fg);
        sn = sn + 1;
      elseif sn = st_numpoints(fg) then
        fg = stc_move_up(fg);
        fg = stc_move_up(fg);
        fg = stc_move_up(fg);
        sn = 4;
      elseif sn = st_numpoints(fg) - 1 then
        fg = stc_move_up(fg);
        fg = stc_move_up(fg);
        fg = stc_move_up(fg);
        fg = stc_move_up(fg);
        sn = 4;
      end if;
      ig = fg;
    end if;

    ----------------------------------------------------------------------
    -- calculate lengths and azimuths of shortest and neighbouring edges
    ----------------------------------------------------------------------
    aze = degrees(st_azimuth(st_pointn(fg, sn-1),   st_pointn(fg, sn)));

    azp = degrees(st_azimuth(st_pointn(fg, sn),   st_pointn(fg, sn+1)));
    lp  = st_length(st_makeline(st_pointn(fg, sn), st_pointn(fg, sn+1)));
    if dg then insert into temp values (7, (st_makeline(st_pointn(fg, sn), st_pointn(fg, sn+1)))); end if;

    azm = degrees(st_azimuth(st_pointn(fg, sn-2), st_pointn(fg, sn-1)));
    lm  = st_length(st_makeline(st_pointn(fg, sn-2), st_pointn(fg, sn-1)));
    if dg then insert into temp values (7, (st_makeline(st_pointn(fg, sn-2), st_pointn(fg, sn-1)))); end if;
    --raise notice 'degrees % %', azm, azp;

    if dg then
      insert into temp values (99,  st_pointn(fg, sn-1));
      insert into temp values (100, st_pointn(fg, sn));
      insert into temp values (101, st_pointn(fg, sn+1));
    end if;

    -- Calculat if it is an extrusion or intrusion
    ac = azp - aze;
    if ac > 180 then ac = ac - 360;
    elseif ac < -180 then ac = ac + 360;
    end if;
    --raise notice 'ac=%', ac;
    intrusion = ac < 0;

    -- calculate change of angles between shortest and neighbouring edges
    ac := azp - azm;
/*    if ac > 180 then
      ac := -180 + (ac % 180);
    elseif ac < -180 then
      ac :=  180 - (abs(ac) % 180);
    end if;*/
    if ac > 180 then ac = ac - 360;
    elseif ac < -180 then ac = ac + 360;
    end if;
    --if dg then raise notice 'diff ac=% edgelength=%', ac, st_length(edge); end if; -- debug

    --------------
    -- CHANGE ~0
    --------------
    if ac between -40 and 40 then
      if dg then raise notice 'CHANGE 0 (ac=% edgelength=%)', ac, st_length(edge); end if; -- debug
      if lm > lp then
        --raise notice '>';
        l1 = st_makeline(
               st_pointn(fg, sn-1),
               st_transform(st_project(st_transform(st_pointn(fg, sn-1), 4326), 1000, pi() * azm / 180.0)::geometry, 3857)
             );
        az = degrees(st_azimuth(st_pointn(fg, sn+1), st_pointn(fg, sn+2)));
        ew = st_makeline(st_pointn(fg, sn+1), st_pointn(fg, sn+2));
        if dg then insert into temp values (10, ew); end if;
        np = st_intersection(l1, ew);
        if st_isempty(np) then
          l2 = st_makeline(
                 st_pointn(fg, sn+1),
                 st_transform(st_project(st_transform(st_pointn(fg, sn+1), 4326), -1000, pi() * az / 180.0)::geometry, 3857)
               );
          np = st_intersection(l1, l2);
        end if;
        if st_isempty(np) then
          ex = st_union(ex, edge);
        else
          fg = st_setpoint(fg, sn-1, np);
          fg = st_setpoint(fg, sn, np);
        end if;
      else
        --raise notice '<';
        l1 = st_makeline(
               st_pointn(fg, sn),
               st_transform(st_project(st_transform(st_pointn(fg, sn), 4326), -1000, pi() * azp / 180.0)::geometry, 3857)
             );
        az = degrees(st_azimuth(st_pointn(fg, sn-2), st_pointn(fg, sn-3)));
        ew = st_makeline(st_pointn(fg, sn-2), st_pointn(fg, sn-3));
        if dg then insert into temp values (10, ew); end if;
        np = st_intersection(l1, ew);
        if st_isempty(np) then
          l2 = st_makeline(
                 st_pointn(fg, sn-2),
                 st_transform(st_project(st_transform(st_pointn(fg, sn-2), 4326), -1000, pi() * az / 180.0)::geometry, 3857)
               );
          np = st_intersection(l1, l2);
          if st_isempty(np) then
            if sn-4 = 0 then
              az = degrees(st_azimuth(st_pointn(fg, -2), st_pointn(fg, sn-3)));
            else
              az = degrees(st_azimuth(st_pointn(fg, sn-4), st_pointn(fg, sn-3)));
            end if;
            l2 = st_makeline(
                   st_pointn(fg, sn-3),
                   st_transform(st_project(st_transform(st_pointn(fg, sn-3), 4326), 1000, pi() * az / 180.0)::geometry, 3857)
                 );
            np = st_intersection(l1, l2);
          end if;
        end if;
        if st_isempty(np) then
          ex = st_union(ex, edge);
        else
          fg = st_setpoint(fg, sn-1, np);
          fg = st_setpoint(fg, sn-2, np);
          fg = st_setpoint(fg, sn-3, np);
        end if;
      end if;

    -------------------
    -- CHANGE 180 EXT
    -------------------
    elseif (ac between 160 and 180 or ac between -180 and -160) and not intrusion then
      if dg then raise notice 'CHANGE +180 EXT (ac=% edgelength=%)', ac, st_length(edge); end if; -- debug
      if lp > t and lm > t then
        if lp > lm then
          az = degrees(st_azimuth(st_pointn(fg, sn), st_pointn(fg, sn-1)));
          np = st_transform(st_project(st_transform(st_pointn(fg, sn-1), 4326), t - st_length(edge) + 0.1, pi() * az / 180.0)::geometry, 3857);
          az = degrees(st_azimuth(st_pointn(fg, sn-1), st_pointn(fg, sn-2)));
          l1 = st_makeline(
                 np,
                 st_transform(st_project(st_transform(np, 4326), 1000, pi() * az / 180.0)::geometry, 3857)
               );
          np2 = st_closestpoint(st_intersection(fg, l1), np);
          if not st_isempty(np2) then
            fg = st_setpoint(fg, sn-2, np);
            fg = st_setpoint(fg, sn-3, np2);
          else
            az = degrees(st_azimuth(st_pointn(fg, sn), st_pointn(fg, sn-1)));
            l1 = st_makeline(
                   st_pointn(fg, sn-1),
                   st_transform(st_project(st_transform(st_pointn(fg, sn-1), 4326), 1000, pi() * az / 180.0)::geometry, 3857)
                 );
            if sn - 4 = 0 then
              az = degrees(st_azimuth(st_pointn(fg, -2),   st_pointn(fg, sn-3)));
            else
              az = degrees(st_azimuth(st_pointn(fg, sn-4), st_pointn(fg, sn-3)));
            end if;
            l2 = st_makeline(
                   st_pointn(fg, sn-3),
                   st_transform(st_project(st_transform(st_pointn(fg, sn-3), 4326), 1000, pi() * az / 180.0)::geometry, 3857)
                 );
            np = st_intersection(l1, l2);
            if not st_isempty(np) then
              fg = st_setpoint(fg, sn-2, np);
              fg = st_setpoint(fg, sn-3, np);
              --fg = st_setpoint(fg, sn-3, np);
            else
              raise notice 'TODO A';
              ex = st_union(ex, edge);
            end if;
          end if;
        else
          az = degrees(st_azimuth(st_pointn(fg, sn-1), st_pointn(fg, sn)));
          np = st_transform(st_project(st_transform(st_pointn(fg, sn), 4326), t - st_length(edge) + 0.1, pi() * az / 180.0)::geometry, 3857);
          az = degrees(st_azimuth(st_pointn(fg, sn), st_pointn(fg, sn+1)));
          l1 = st_makeline(
                 np,
                 st_transform(st_project(st_transform(np, 4326), 1000, pi() * az / 180.0)::geometry, 3857)
               );
          np2 = st_closestpoint(st_intersection(fg, l1), np);
          if not st_isempty(np) and not st_isempty(np2) then
            fg = st_setpoint(fg, sn-1, np);
            fg = st_setpoint(fg, sn, np2);
          else
            raise notice 'TODO B';
            ex = st_union(ex, edge);
          end if;
        end if;
      else
        az = degrees(st_azimuth(st_pointn(fg, sn-3), st_pointn(fg, sn-2)));
        l1 = st_makeline(
               st_pointn(fg, sn-2),
               st_transform(st_project(st_transform(st_pointn(fg, sn-2), 4326), 1000, pi() * az / 180.0)::geometry, 3857)
             );
        ew = st_makeline(st_pointn(fg, sn), st_pointn(fg, sn+1));
        np = st_intersection(l1, ew);

        az = degrees(st_azimuth(st_pointn(fg, sn+2), st_pointn(fg, sn+1)));
        l2 = st_makeline(
               st_pointn(fg, sn+1),
               st_transform(st_project(st_transform(st_pointn(fg, sn+1), 4326), 1000, pi() * az / 180.0)::geometry, 3857)
             );
        np2 = st_intersection(l1, l2);
        if not st_isempty(np2) and st_contains(st_makepolygon(fg), np2) then
          fg = st_setpoint(fg, sn-3, np2);
          fg = st_setpoint(fg, sn-2, np2);
          fg = st_setpoint(fg, sn-1, np2);
          fg = st_setpoint(fg, sn, np2);
          np = np2;
        else
          ew = st_makeline(st_pointn(fg, sn-1), st_pointn(fg, sn-2));
          np2 = st_intersection(l2, ew);
          if st_isempty(np) and not st_isempty(np2) then
            fg = st_setpoint(fg, sn, np2);
            fg = st_setpoint(fg, sn-1, np2);
            fg = st_setpoint(fg, sn-2, np2);
          elseif st_isempty(np2) and not st_isempty(np) then
            fg = st_setpoint(fg, sn-1, np);
            fg = st_setpoint(fg, sn-2, np);
            fg = st_setpoint(fg, sn-3, np);
          else
            ew = st_makeline(st_pointn(fg, sn-3), st_pointn(fg, sn-2));
            np = st_intersection(l2, ew);
            if not st_isempty(np) then
              fg = st_setpoint(fg, sn, np);
              fg = st_setpoint(fg, sn-1, np);
              fg = st_setpoint(fg, sn-2, np);
              fg = st_setpoint(fg, sn-3, np);
            else
              raise notice 'TODO C';
              ex = st_union(ex, edge);
            end if;
          end if;
        end if;
      end if;

    -------------------
    -- CHANGE 180 INT
    -------------------
    elseif (ac between 160 and 180 or ac between -180 and -160) and intrusion then
      if dg then raise notice 'CHANGE +180 INT (ac=% edgelength=%)', ac, st_length(edge); end if; -- debug
      az = degrees(st_azimuth(st_pointn(fg, sn-3), st_pointn(fg, sn-2)));
      l1 = st_makeline(
             st_pointn(fg, sn-2),
             st_transform(st_project(st_transform(st_pointn(fg, sn-2), 4326), 1000, pi() * az / 180.0)::geometry, 3857)
           );
      ew = st_makeline(st_pointn(fg, sn), st_pointn(fg, sn+1));
      np = st_intersection(l1, ew);

      az = degrees(st_azimuth(st_pointn(fg, sn+2), st_pointn(fg, sn+1)));
      l2 = st_makeline(
             st_pointn(fg, sn+1),
             st_transform(st_project(st_transform(st_pointn(fg, sn+1), 4326), 1000, pi() * az / 180.0)::geometry, 3857)
           );
      np2 = st_intersection(l1, l2);
      if not st_isempty(np2) and st_contains(st_makepolygon(fg), np2) then
        raise notice 'TODO D';
        ex = st_union(ex, edge);
        -- perkelti visus taškus į np2?
      else
        ew = st_makeline(st_pointn(fg, sn-1), st_pointn(fg, sn-2));
        np2 = st_intersection(l2, ew);
        if st_isempty(np) and not st_isempty(np2) then
          fg = st_setpoint(fg, sn, np2);
          fg = st_setpoint(fg, sn-1, np2);
          fg = st_setpoint(fg, sn-2, np2);
        elseif st_isempty(np2) and not st_isempty(np) then
          fg = st_setpoint(fg, sn-1, np);
          fg = st_setpoint(fg, sn-2, np);
          fg = st_setpoint(fg, sn-3, np);
        else
          ew = st_makeline(st_pointn(fg, sn-3), st_pointn(fg, sn-2));
          np = st_intersection(l2, ew);
          if not st_isempty(np) then
            fg = st_setpoint(fg, sn, np);
            fg = st_setpoint(fg, sn-1, np);
            fg = st_setpoint(fg, sn-2, np);
            fg = st_setpoint(fg, sn-3, np);
          else
            raise notice 'TODO E';
            ex = st_union(ex, edge);
          end if;
        end if;
      end if;

    --------------
    -- CHANGE 90
    --------------
    elseif (ac between 50 and 110) or
           (ac between -110 and -50) then
      if dg then raise notice 'CHANGE 90 (ac=% edgelength=%)', ac, st_length(edge); end if; -- debug
      l1 = st_makeline(
             st_pointn(fg, sn-2),
             st_transform(st_project(st_transform(st_pointn(fg, sn-1), 4326), 100, pi() * azm / 180.0)::geometry, 3857)
           );
      l2 = st_makeline(
             st_pointn(fg, sn+1),
             st_transform(st_project(st_transform(st_pointn(fg, sn), 4326), -1000, pi() * azp / 180.0)::geometry, 3857)
           );
      np = st_intersection(l1, l2);
      if not st_isempty(np) then
        fg = st_setpoint(fg, sn-1, np);
        fg = st_setpoint(fg, sn-2, np);
      else
        ex = st_union(ex, edge);
      end if;

    -----------------
    -- UNPOCESSABLE
    -----------------
    elseif (ac between -160 and -110) or
           (ac between -50 and -40) or
           (ac between 40 and 50) or
           (ac between 110 and 160) then
      ex = st_union(ex, edge);

    else
      if dg then raise notice 'UNSUPPORTED ac=%', ac;
      else raise 'UNSUPPORTED ac=%', ac; end if;
      ex = st_union(ex, edge);
    end if;

    -- remove irrelevant vertexes
    fg = stc_simplify_turbo(fg);

    -- debug
    if dg then insert into temp values (2, l1); end if;
    if dg then insert into temp values (2, l2); end if;
    if dg then insert into temp values (3, np); end if;
    if dg then insert into temp values (3, np2); end if;
    if dg then insert into temp values (4, fg); end if;
    if dg then insert into temp values (9, ex); end if;

    fg = stc_remove_spike(fg);
    fg = stc_simplify_angle(fg);
    fg = stc_simplify_angle(fg);

    if st_numpoints(fg) < 5 then
      raise notice 'EXCEPTION. TOO MANY NODES REMOVED';
      return ig;
    elseif not st_issimple(fg) then
      raise notice 'EXCEPTION. NOT SIMPLE RESULT';
      ex = st_union(ex, edge);
      if dg then insert into temp values (9, ex); end if;
      fg = stc_simplify_turbo(ig);
    --raise notice '% / % = %', st_area(st_makepolygon(fg)), st_area(st_makepolygon(r)), st_area(st_makepolygon(fg)) * 1.0 / st_area(st_makepolygon(r));
    --if (st_area(st_makepolygon(fg)) * 1.0 / st_area(st_makepolygon(r)) < 0.67) or
    elseif (st_area(st_makepolygon(fg)) < 100) then
      raise notice 'EXCEPTION. FINAL AREA < 100';
      ex = st_union(ex, edge);
      if dg then insert into temp values (9, ex); end if;
      fg = stc_simplify_turbo(ig);
    end if;
  end loop;
end
$$ language plpgsql;
