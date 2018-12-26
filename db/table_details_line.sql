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
  coalesce(man_made, "natural",
    case when waterway = 'dam' then 'dam'
         when waterway = 'weir' then 'dam'
    end
  ) AS kind
FROM
  planet_osm_line
WHERE
  (man_made = 'cutline' OR
   "natural" = 'cliff' OR
   waterway in ('dam', 'weir'));
