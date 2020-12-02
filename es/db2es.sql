WITH t1 AS (
    SELECT
        osm_id * 10 + 1 AS id, -- point, "taškas"
        case when historic = 'archaeological_site' and site_type = 'fortification' then 'HIL'
             when historic = 'archaeological_site' and site_type = 'tumulus' then 'TUM'
             when historic = 'manor' then 'MAN'
             when historic = 'monastery' then 'MNS'
             when historic in ('monument', 'memorial') then 'MON'
             when historic is not null then 'HIS'
             when "ref:lt:kpd" is not null then 'HER'
             when man_made in ('tower', 'communications_tower') and "tower:type" is not null and tourism in ('attraction', 'viewpoint', 'museum') and coalesce(access, 'yes') != 'no' then 'TOW'
             when tourism in ('attraction', 'theme_park', 'zoo', 'aquarium') then 'ATT'
             when tourism = 'viewpoint' then 'VIE'
             when tourism = 'museum' then 'MUS'
             /*when (tourism = 'picnic_site' or amenity = 'shelter') and fireplace = 'yes' then 'PIF'
             when (tourism = 'picnic_site' or amenity = 'shelter') and (fireplace is null or fireplace = 'no') then 'PIC'*/
             when (tourism = 'picnic_site' or amenity = 'shelter') then 'PIF'
             when tourism = 'camp_site' then 'CAM'
             when tourism in ('chalet', 'hostel', 'motel', 'guest_house') then 'GUE'
             when amenity = 'fuel' then 'FUE'
             when amenity = 'cafe' then 'CAF'
             when amenity = 'fast_food' then 'FAS'
             when amenity = 'restaurant' then 'RES'
             when amenity in ('pub', 'bar') then 'PUB'
             when tourism = 'hotel' then 'HOT'
             when amenity = 'theatre' then 'THE'
             when amenity = 'cinema' then 'CIN'
             when amenity = 'arts_centre' then 'ART'
             when amenity = 'library' then 'LIB'
             when amenity = 'hospital' then 'HOS'
             when amenity = 'clinic' then 'CLI'
             when amenity = 'dentist' then 'DEN'
             when amenity = 'doctors' then 'DOC'
             when amenity = 'pharmacy' then 'PHA'
             when shop in ('supermarket', 'mall') then 'SUP'
             when shop = 'convenience' then 'CON'
             when shop = 'car_repair' then 'CAR'
             when shop = 'kiosk' then 'KIO'
             when shop = 'doityourself' then 'DIY'
             when amenity = 'place_of_worship' and religion = 'christian' and denomination in ('catholic', 'roman_catholic') then 'CHU'
             when amenity = 'place_of_worship' and religion = 'christian' and denomination in ('lutheran', 'evangelical', 'reformed') then 'LUT'
             when amenity = 'place_of_worship' and religion = 'christian' and denomination = 'orthodox' then 'ORT'
             when amenity = 'place_of_worship' and (religion != 'christian' or coalesce(denomination, '@') not in ('catholic', 'roman_catholic', 'lutheran', 'evangelical', 'reformed', 'orthodox')) then 'ORE'
             when office = 'government' or amenity = 'townhall' then 'GOV'
             when amenity = 'courthouse' then 'COU'
             when office = 'notary' then 'NOT'
             when office = 'insurance' then 'INS'
             when office is not null and office not in ('government', 'notary') then 'COM'
             when shop is not null and shop not in ('supermarket', 'mall', 'convenience', 'car_repair', 'kiosk', 'doityourself') then 'OSH'
             when amenity = 'post_office' then 'POS'
             when amenity = 'car_wash' then 'WAS'
             when amenity = 'bank' then 'BAN'
             when amenity = 'atm' then 'ATM'
             when "natural" = 'stone' then 'STO'
             when "natural" = 'tree' then 'TRE'
             when "natural" = 'spring' then 'SPR'
             else 'DEF' end AS obj_type,
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
        osm_id * 10 + 2 AS id, -- polygon, "daugiakampis"
        case when historic = 'archaeological_site' and site_type = 'fortification' then 'HIL'
             when historic = 'archaeological_site' and site_type = 'tumulus' then 'TUM'
             when historic = 'manor' then 'MAN'
             when historic = 'monastery' then 'MNS'
             when historic in ('monument', 'memorial') then 'MON'
             when historic is not null then 'HIS'
             when "ref:lt:kpd" is not null then 'HER'
             when man_made in ('tower', 'communications_tower') and "tower:type" is not null and tourism in ('attraction', 'viewpoint', 'museum') and coalesce(access, 'yes') != 'no' then 'TOW'
             when tourism in ('attraction', 'theme_park', 'zoo', 'aquarium') then 'ATT'
             when tourism = 'viewpoint' then 'VIE'
             when tourism = 'museum' then 'MUS'
             /*when (tourism = 'picnic_site' or amenity = 'shelter') and fireplace = 'yes' then 'PIF'
             when (tourism = 'picnic_site' or amenity = 'shelter') and (fireplace is null or fireplace = 'no') then 'PIC'*/
             when (tourism = 'picnic_site' or amenity = 'shelter') then 'PIF'
             when tourism = 'camp_site' then 'CAM'
             when tourism in ('chalet', 'hostel', 'motel', 'guest_house') then 'GUE'
             when amenity = 'fuel' then 'FUE'
             when amenity = 'cafe' then 'CAF'
             when amenity = 'fast_food' then 'FAS'
             when amenity = 'restaurant' then 'RES'
             when amenity in ('pub', 'bar') then 'PUB'
             when tourism = 'hotel' then 'HOT'
             when amenity = 'theatre' then 'THE'
             when amenity = 'cinema' then 'CIN'
             when amenity = 'arts_centre' then 'ART'
             when amenity = 'library' then 'LIB'
             when amenity = 'hospital' then 'HOS'
             when amenity = 'clinic' then 'CLI'
             when amenity = 'dentist' then 'DEN'
             when amenity = 'doctors' then 'DOC'
             when amenity = 'pharmacy' then 'PHA'
             when shop in ('supermarket', 'mall') then 'SUP'
             when shop = 'convenience' then 'CON'
             when shop = 'car_repair' then 'CAR'
             when shop = 'kiosk' then 'KIO'
             when shop = 'doityourself' then 'DIY'
             when amenity = 'place_of_worship' and religion = 'christian' and denomination in ('catholic', 'roman_catholic') then 'CHU'
             when amenity = 'place_of_worship' and religion = 'christian' and denomination in ('lutheran', 'evangelical', 'reformed') then 'LUT'
             when amenity = 'place_of_worship' and religion = 'christian' and denomination = 'orthodox' then 'ORT'
             when amenity = 'place_of_worship' and (religion != 'christian' or coalesce(denomination, '@') not in ('catholic', 'roman_catholic', 'lutheran', 'evangelical', 'reformed', 'orthodox')) then 'ORE'
             when office = 'government' or amenity = 'townhall' then 'GOV'
             when amenity = 'courthouse' then 'COU'
             when office = 'notary' then 'NOT'
             when office = 'insurance' then 'INS'
             when office is not null and office not in ('government', 'notary') then 'COM'
             when shop is not null and shop not in ('supermarket', 'mall', 'convenience', 'car_repair', 'kiosk', 'doityourself') then 'OSH'
             when amenity = 'post_office' then 'POS'
             when amenity = 'car_wash' then 'WAS'
             when amenity = 'bank' then 'BAN'
             when amenity = 'atm' then 'ATM'
             when "natural" = 'stone' then 'STO'
             when "natural" = 'tree' then 'TRE'
             when "natural" = 'spring' then 'SPR'
             else 'DEF' end AS obj_type,
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
        case when object_type = 'r' then id * 10 + 3
             when object_type = 's' then id * 10 + 4
        end AS id,
        case when object_type = 'r' then 'RIV'
             when object_type = 's' then 'STR'
             else 'DEF'
        end AS obj_type,
        null AS city,
        null AS street,
        null AS housenumber,
        null AS postcode,
        null AS unit,
        ao.name AS name,
        null AS alt_name,
        null AS official_name,
        null AS description,
        ST_Transform(ST_ClosestPoint(ao.way, ST_Centroid(ao.way)), 4326) AS location
    FROM
        agg_objects ao
)
SELECT
    json_strip_nulls (row_to_json(t2))
FROM (
    SELECT
        id,
        obj_type,
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
