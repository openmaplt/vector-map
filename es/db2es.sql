WITH t1 AS (
    SELECT
        't' || osm_id AS id, -- point, "taškas"
        "addr:city" AS city,
        "addr:street" AS street,
        "addr:housenumber" AS housenumber,
        "addr:postcode" AS postcode,
        "addr:unit" AS unit,
        COALESCE("name:lt", name) AS name,
        alt_name AS alt_name,
        official_name AS official_name,
        description AS description,
        ST_Transform (way, 4326) AS location
    FROM
        planet_osm_point
    WHERE
        historic IS NOT NULL
        OR tourism IN ('hotel', 'motel', 'hostel', 'guest_house', 'camp_site', 'caravan_site')
        OR amenity IN ('restaurant', 'cafe', 'bar', 'pub')
        OR tourism IN ('museum', 'attraction', 'viewpoint')
        OR admin_level IS NOT NULL
        OR "addr:city" IS NOT NULL
    UNION
    SELECT
        'd' || osm_id AS id, -- polygon, "daugiakampis"
        "addr:city" AS city,
        "addr:street" AS street,
        "addr:housenumber" AS housenumber,
        "addr:postcode" AS postcode,
        "addr:unit" AS unit,
        COALESCE("name:lt", name) AS name,
        alt_name AS alt_name,
        official_name AS official_name,
        description AS description,
        ST_Transform (ST_PointOnSurface (way), 4326) AS location
    FROM
        planet_osm_polygon
    WHERE
        historic IS NOT NULL
        OR tourism IN ('hotel', 'motel', 'hostel', 'guest_house', 'camp_site', 'caravan_site')
        OR amenity IN ('restaurant', 'cafe', 'bar', 'pub')
        OR tourism IN ('museum', 'attraction', 'viewpoint')
        OR admin_level IS NOT NULL
        OR "addr:city" IS NOT NULL
    UNION
    SELECT
        's' || s.osm_id AS id, -- street
        o."addr:city" AS city,
        o."addr:street" AS street,
        o."addr:housenumber" AS housenumber,
        o."addr:postcode" AS postcode,
        o."addr:unit" AS unit,
        COALESCE(o."name:lt", o.name) AS name,
        o.alt_name AS alt_name,
        o.official_name AS official_name,
        o.description AS description,
        ST_LineInterpolatePoint(ST_Transform(o.way, 4326), 0.5) AS location
    FROM
        agg_streets s, planet_osm_line o
    WHERE s.osm_id = o.osm_id
    UNION
    SELECT
        'r' || r.osm_id AS id, -- rivers
        o."addr:city" AS city,
        o."addr:street" AS street,
        o."addr:housenumber" AS housenumber,
        o."addr:postcode" AS postcode,
        o."addr:unit" AS unit,
        COALESCE(o."name:lt", o.name) AS name,
        o.alt_name AS alt_name,
        o.official_name AS official_name,
        o.description AS description,
        ST_LineInterpolatePoint(ST_Transform(o.way, 4326), 0.5) AS location
    FROM
        agg_rivers r, planet_osm_line o
    WHERE r.osm_id = o.osm_id
)
SELECT
    json_strip_nulls (row_to_json(t2))
FROM (
    SELECT
        id,
        city,
        street,
        housenumber,
        postcode,
        unit,
        name,
        alt_name,
        official_name,
        description,
        ARRAY[ST_Y (location), ST_X (location)] AS location
    FROM
        t1) AS t2
