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
       when highway is not null then 'dam_highway'
       when waterway = 'dam' then 'dam'
  end AS kind,
  highway
FROM
  planet_osm_line
WHERE
  (man_made = 'cutline' OR
   "natural" = 'cliff' OR
   waterway = 'dam';
