create or replace function stc_process_centerlines(p_limit integer default 100) returns integer as $$
declare
  c record;
  z integer;
  big_enough_multi boolean;
  big_enough_center boolean;
  big_enough_centroid boolean;
  pixelsize float;
  s integer;
  g geometry = null;
  l integer;
  lm integer;
  prop real;
  font_coef real;
  tl real;
  sg geometry;
  count integer = 0;
  total integer;
  start_time timestamp with time zone;
begin
  select count(1) into total from car_requests where dirty = 'Y' or now() - last_update > interval '3 months';
  for c in (select r.id as id
                  ,p.osm_id as osm_id
                  ,stc_text_width(coalesce(p."name:lt", p.name))*2 l
                  ,length(coalesce(p."name:lt", p.name)) ll
                  ,coalesce(p."name:lt", p.name) as name
                  ,case when r.osm_id = -7546467 -- Kuršių nerija
                     then st_intersection(p.way, st_geomfromtext('POLYGON((2335964.25118912 7409562.69788629,2335964.25118912 7504900.70614382,2370109.23407235 7504900.70614382,2370109.23407235 7409562.69788629,2335964.25118912 7409562.69788629))', 3857))
                     else p.way
                   end as way
              from car_requests r
                  ,planet_osm_polygon p
             where p.osm_id = r.osm_id
               and (r.dirty = 'Y' or
                    now() - r.last_update > interval '1 month'
                   )
             order by st_area(p.way) desc
             limit p_limit) loop
    start_time = clock_timestamp();
    count = count + 1;
    raise notice '=======================================================';
    raise notice 'Processing object % osm_id=% (%/%)', c.name, c.osm_id, count, total;
    --z = 18;
    --pixelsize = 0.5; -- 18 zoom 1 pixel = 0,5 meters
    z = 17;
    pixelsize = 1;
    --z = 16; pixelsize = 2;
    --z = 15; pixelsize = 4;
    --z = 14; pixelsize = 8;
    s = 30;
    big_enough_multi = true;
    big_enough_center = false;
    big_enough_centroid = false;
    delete from car_labels where osm_id = c.osm_id;
    delete from car_centerline where osm_id = c.osm_id;
    while z > 8 loop
      raise notice '----------------------------------';
      raise notice 'Zoom %', z;
      raise notice 'text_width=% pixelsize=% finalsize=%', c.l, pixelsize, cast(c.l * pixelsize as integer);
      if big_enough_multi then
        big_enough_multi = stc_polygon_labels(c.id, c.way, z, cast(c.l * pixelsize as integer));
        if big_enough_multi then
          update car_labels
             set name = c.name
                ,osm_id = c.osm_id
                ,id = nextval('car_labels_seq')
           where id = 1 and zoom = z;
        else
          raise notice 'Not big enough for multi-labels';
          big_enough_center = true;
          continue;
        end if;
      end if;
      if big_enough_center then
        raise notice 'Calculating center line for zoom=%', z;
        g = null;
        while g is null and s > 8 loop
          delete from car_polygon;
          -- NOTE: We're using type size - 3 here to have a smoother line with
          --       the slight risk that label will not fit fully into waterbody.
          g = stc_centerline(c.way, cast((s - 3) * pixelsize as int));
          if g is null then
            raise notice 'got no result for type size=% (% pixels)', s, s * pixelsize;
            s = s - 1;
          else
            lm = st_length(g);
            font_coef = c.l * s / 28 * pixelsize;
            raise notice '(type size %) got geometry length % for text length %', s, lm, font_coef;
            if (lm < font_coef) then
              g = null;
              s = s - 1;
            else
              prop = |/ ((st_xmax(c.way) - st_xmin(c.way))^2 +
                         (st_ymax(c.way) - st_ymin(c.way))^2);
              -- TODO: Different calculation should be done for multigeometries (parts > 1)
              if (prop * 0.5 < lm) or (st_numgeometries(c.way) > 1) then
                raise notice 'GOT GOOD RESULT!!! propotion % (length %<%) (geometry count=%)', lm / font_coef, prop, lm, st_numgeometries(c.way);
                if lm / font_coef < 1.07 then
                  prop = 0.2;
                elseif lm / font_coef < 1.1 then
                  prop = 0.3;
                elseif lm / font_coef < 1.2 then
                  prop = 0.4;
                elseif lm / font_coef < 1.29 then
                  prop = 0.5;
                elseif lm / font_coef < 1.52 then
                  prop = 0.6;
                elseif lm / font_coef < 1.65 then
                  prop = 0.7;
                elseif lm / font_coef < 1.73 then
                  prop = 0.8;
                elseif lm / font_coef < 1.81 then
                  prop = 0.9;
                else
                  prop = 1.0;
                end if;
                tl = lm / pixelsize / 512;
                if tl > 4 then
                  raise notice 'Centerline is long enough to be broken into parts (length=% tiles)', tl;
                  sg = null;
                  while tl > 4 loop
                    raise notice 'splitting at % (length %)', 2.0 / tl, st_length(g);
                    g = st_split(g, st_buffer(st_LineInterpolatePoint(g, 2.0 / tl), 10));
                    insert into car_centerline (id, osm_id, name, zoom, size, spacing, way) values (1, c.osm_id, c.name, z, s, prop, st_geometryn(g, 1));
                    -- note: 2nd geometry is a buffer zone between two parts
                    g = st_geometryn(g, 3);
                    tl = tl - 2;
                  end loop;
                  insert into car_centerline (id, osm_id, name, zoom, size, spacing, way) values (1, c.osm_id, c.name, z, s, prop, g);
                else
                  insert into car_centerline (id, osm_id, name, zoom, size, spacing, way) values (1, c.osm_id, c.name, z, s, prop, g);
                end if;
              else
                g = null;
                s = s - 1;
                raise notice 'Diagonal length is much larger: %, centerline length %', prop, lm;
              end if;
            end if;
          end if;
        end loop;
        if g is null then
          big_enough_center = false;
          big_enough_centroid = true;
          raise notice 'Not big enough for center line';
        end if;
      end if;
      if big_enough_centroid then
        l = greatest((st_xmax(c.way) - st_xmin(c.way)) / pixelsize,
                     (st_ymax(c.way) - st_ymin(c.way)) / pixelsize);
        if l > 50 then
          raise notice 'Big enough for centroid label';
          s = cast(l as float) / c.l * 28;
          raise notice '% / % * 28 = %', l, c.l, s;
          if s > 14 then s = 14; end if; -- maximum center label size is 12
          if s > 6 then
            insert into car_labels values (
              nextval('car_labels_seq')
             ,c.osm_id
             ,c.name
             ,z
             ,s /* font size */
             ,0.1 /* letter spacing */
             ,st_pointonsurface(c.way)
            );
          else
            raise notice 'not big enough for centroid label (2)';
            big_enough_centroid = false;
          end if;
        else
          raise notice 'not big enough for centroid label (1)';
          big_enough_centroid = false;
        end if;
      end if;
      z = z - 1;
      pixelsize = pixelsize * 2;
    end loop;
    update car_requests set
        last_update = now(),
        dirty = 'N',
        duration = extract(epoch from clock_timestamp()) - extract(epoch from start_time)
      where id = c.id;
  end loop;
  return 0;
end$$ language plpgsql;
