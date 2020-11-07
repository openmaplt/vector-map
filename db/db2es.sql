SELECT
    json_strip_nulls (row_to_json(t))
FROM (
    SELECT
        osm_id AS id,
        "addr:city" AS city,
        "addr:street" AS street,
        "addr:housenumber" AS housenumber,
        "addr:postcode" AS postcode,
        "addr:unit" AS unit,
        name AS name,
        alt_name AS alt_name,
        official_name AS official_name,
        description AS description,
        ST_AsText (ST_Transform (way, 4326)) AS location
    FROM
        planet_osm_point
    WHERE
        historic IS NOT NULL
        OR tourism IN ('hotel', 'motel', 'hostel', 'guest_house', 'camp_site', 'caravan_site')
        OR amenity IN ('restaurant', 'cafe', 'bar', 'pub')
        OR tourism IN ('museum', 'attraction', 'viewpoint')
        OR waterway IN ('river', 'stream', 'canal')
        OR admin_level IS NOT NULL
        OR "addr:city" IS NOT NULL
    UNION
    SELECT
        osm_id AS id,
        "addr:city" AS city,
        "addr:street" AS street,
        "addr:housenumber" AS housenumber,
        "addr:postcode" AS postcode,
        "addr:unit" AS unit,
        name AS name,
        alt_name AS alt_name,
        official_name AS official_name,
        description AS description,
        ST_AsText (ST_Transform (ST_PointOnSurface (way), 4326)) AS location
    FROM
        planet_osm_polygon
    WHERE
        historic IS NOT NULL
        OR tourism IN ('hotel', 'motel', 'hostel', 'guest_house', 'camp_site', 'caravan_site')
        OR amenity IN ('restaurant', 'cafe', 'bar', 'pub')
        OR tourism IN ('museum', 'attraction', 'viewpoint')
        OR waterway IN ('river', 'stream', 'canal')
        OR admin_level IS NOT NULL
        OR "addr:city" IS NOT NULL) AS t
