SELECT
  osm_id AS gid,
  st_asmvtgeom(way,!BBOX!) AS geom,
  (
    CASE
      WHEN waterway = 'river'
        THEN 'river'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name,
  case when "waterway:speed" is null then 'N' else 'Y' end as virtual
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  waterway = 'river'
