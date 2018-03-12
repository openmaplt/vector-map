CREATE OR REPLACE FUNCTION remove_outside_objects() RETURNS int AS $$
declare
  count integer := 0;
  total integer := 0;
begin
  delete from planet_osm_line  where osm_id in (select osm_id from outside_objects where type = 'W');
  get diagnostics total = row_count;

  delete from planet_osm_roads where osm_id in (select osm_id from outside_objects where type = 'W');
  get diagnostics count = row_count;
  total := total + count;

  delete from planet_osm_ways  where     id in (select osm_id from outside_objects where type = 'W');
  get diagnostics count = row_count;
  total := total + count;

  delete from planet_osm_polygon where osm_id in (select osm_id from outside_objects where type = 'PO');
  get diagnostics count = row_count;
  total := total + count;

  delete from planet_osm_point where osm_id in (select osm_id from outside_objects where type = 'PT');
  get diagnostics count = row_count;
  total := total + count;

  return total;
end;
$$ language plpgsql;

select remove_outside_objects();
