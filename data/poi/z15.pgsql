SELECT
  id,
  id AS gid,
  __type__,
  ST_AsMVTGeom(way,!BBOX!) AS geom,
  name,
  (
    CASE
    WHEN amenity = 'fuel'
      THEN 'fuel'
    WHEN amenity = 'place_of_worship'
      THEN 'place_of_worship'

    WHEN man_made = 'tower' and "tower:type" is not null and tourism in ('attraction', 'viewpoint', 'museum') and coalesce(access, 'yes') != 'no'
      THEN 'marker' /* TODO: tower */

    WHEN tourism = 'attraction' and "attraction:type" = 'hiking_route'
      THEN 'hiking'
    WHEN tourism = 'information'
      THEN 'information'
    WHEN tourism in ('camp_site', 'caravan_site')
      THEN 'campsite'
    WHEN tourism in ('chalet', 'hostel', 'motel', 'guest_house')
      THEN 'home' /* TODO: split, fix icon */
    WHEN tourism = 'hotel'
      THEN 'lodging'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'picnic_site'
      THEN 'picnic-site'
    WHEN tourism = 'viewpoint'
      THEN 'viewpoint'

    WHEN historic = 'archaeological_site' and site_type = 'fortification'
      THEN 'hillfort'
    WHEN historic in ('monument', 'memorial')
      THEN 'memorial'
    WHEN historic = 'archaeological_site' and site_type = 'tumulus'
      THEN 'tumulus'
    WHEN historic = 'manor'
      THEN 'marker' /* TODO: manor */
    WHEN historic = 'monastery'
      THEN 'marker' /* TODO: monastery */
    WHEN historic = 'castle'
      THEN 'castle'

    WHEN tourism = 'attraction'
      THEN 'attraction'
    END
  ) AS kind,
  official_name,
  alt_name,
  opening_hours,
  website,
  image,
  "ref:lt:kpd" AS heritage,
  height,
  wikipedia,
  fee,
  email,
  phone,
  "addr:city" AS city,
  "addr:street" AS street,
  "addr:housenumber" AS housenumber,
  "addr:postcode" AS post_code
FROM
  poi
WHERE
  way && !BBOX! AND
  (
    amenity IN ('fuel',
                'place_of_worship') OR
    tourism IN ('attraction',
                'camp_site',
                'caravan_site',
                'chalet',
                'hostel',
                'motel',
                'guest_house',
                'hotel',
                'museum',
                'picnic_site',
                'viewpoint') OR
    (tourism = 'information' and information = 'office') OR
    historic IN ('archaeological_site',
                 'castle',
                 'monument',
                 'memorial',
                 'manor',
                 'monastery')
  )
ORDER BY
  CASE WHEN tourism = 'attraction' then 1
       WHEN tourism = 'viewpoint' then 2
       WHEN tourism in ('camp_site', 'caravan_site') then 3
       WHEN tourism is not null then 4
       WHEN historic is not null then 5
       WHEN amenity is not null then 6
       ELSE 7
  END
