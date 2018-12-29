drop materialized view if exists details_line;
create materialized view details_line (
  gid,
  wkb,
  geom,
  kind
) as
SELECT
  osm_id AS gid,
  ST_AsBinary(way),
  way,
  case when man_made = 'cutline' then 'cutline'
       when "natural" = 'cliff' then 'cliff'
       when waterway in ('dam', 'weir') then 'dam'
       when highway is not null and man_made = 'embankment' then 'dam_highway'
       when man_made = 'embankment' then 'dam'
  end AS kind
FROM
  planet_osm_line
WHERE
  (man_made = 'cutline' OR
   "natural" = 'cliff' OR
   waterway in ('dam', 'weir') OR
   (man_made = 'embankment' and "embankment:type" = 'dam'));
