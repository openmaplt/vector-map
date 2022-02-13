SELECT
  id,
  id AS gid,
  __type__,
  st_asmvtgeom(way,!BBOX!) AS geom,
  name,
  (
    CASE
    WHEN amenity = 'arts_centre'
      THEN 'art-gallery'
    WHEN amenity = 'atm'
      THEN 'marker' /* TODO atm */
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'bicycle_parking'
      THEN 'bicycle_parking'
    WHEN amenity = 'bicycle_rental'
      THEN 'bicycle_rental'
    WHEN amenity = 'bus_station'
      THEN 'bus'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'car_wash'
      THEN 'marker' /* TODO: car_wash */
    WHEN amenity = 'cinema'
      THEN 'cinema'
    WHEN amenity = 'clinic'
      THEN 'marker' /* TODO: clinic */
    WHEN amenity = 'courthouse'
      THEN 'marker' /* TODO: courthouse */
    WHEN amenity = 'compressed_air'
      THEN 'compressed_air'
    WHEN amenity = 'dentist'
      THEN 'dentist'
    WHEN amenity = 'doctors'
      THEN 'doctor'
    WHEN amenity = 'fast_food'
      THEN 'fast-food'
    WHEN amenity = 'fire_station'
      THEN 'fire-station'
    WHEN amenity = 'fuel'
      THEN 'fuel'
    WHEN amenity = 'hospital'
      THEN 'hospital'
    WHEN amenity = 'kindergarten'
      THEN 'scooter'
    WHEN amenity = 'library'
      THEN 'library'
    WHEN amenity = 'pharmacy'
      THEN 'pharmacy'
    WHEN amenity = 'place_of_worship'
      THEN 'place_of_worship'
    WHEN amenity = 'police'
      THEN 'police'
    WHEN amenity = 'post_office'
      THEN 'post'
    WHEN amenity = 'pub'
      THEN 'beer'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN amenity = 'school'
      THEN 'school'
    WHEN amenity = 'shelter'
      THEN 'shelter'
    WHEN amenity = 'theatre'
      THEN 'theatre'
    WHEN amenity in ('college', 'university')
      THEN 'college'

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
    WHEN tourism = 'zoo'
      THEN 'zoo'
    WHEN tourism = 'theme_park'
      THEN 'theme_park'

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

    WHEN tourism = 'attraction'
      THEN 'attraction'

    WHEN railway = 'station'
      THEN 'rail'
    WHEN aeroway = 'terminal'
      THEN 'airport'
    WHEN aeroway = 'helipad'
      THEN 'heliport'
    WHEN aeroway = 'aerodrome'
      THEN 'airfield'
    WHEN amenity = 'ferry_terminal'
      THEN 'ferry'

    WHEN shop = 'alcohol'
      THEN 'alcohol-shop'
    WHEN shop = 'car_repair'
      THEN 'marker' /* TODO car repair */
    WHEN shop = 'tyres'
      THEN 'marker' /* TODO tyres */
    WHEN shop = 'bakery'
      THEN 'bakery'
    WHEN shop = 'bicycle'
      THEN 'bicycle'
    WHEN shop = 'clothes'
      THEN 'clothing-store'
    WHEN shop in ('supermarket', 'mall', 'department_store')
      THEN 'grocery'
    WHEN shop in ('convenience')
      THEN 'shop'
    WHEN shop = 'hairdresser'
      THEN 'hairdresser'
    WHEN shop = 'florist'
      THEN 'florist'
    WHEN shop = 'music'
      THEN 'music'
    WHEN shop = 'butcher'
      THEN 'slaughterhouse'

    WHEN office = 'government' or amenity = 'townhall'
      THEN 'town-hall'
    WHEN office in ('notary', 'lawyer')
      THEN 'marker' /* TODO notary */
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
    amenity IN ('arts_centre',
                'atm',
                'bank',
                'bar',
                'bicycle_parking',
                'bicycle_rental',
                'bus_station',
                'cafe',
                'car_wash',
                'cinema',
                'clinic',
                'college',
                'compressed_air',
                'courthouse',
                'dentist',
                'doctors',
                'fast_food',
                'ferry_terminal',
                'fire_station',
                'fuel',
                'hospital',
                'kindergarten',
                'library',
                'pharmacy',
                'place_of_worship',
                'police',
                'post_office',
                'pub',
                'restaurant',
                'school',
                'shelter',
                'theatre',
                'townhall',
                'university') OR
    tourism IN ('attraction',
                'camp_site',
                'caravan_site',
                'chalet',
                'guest_house',
                'hostel',
                'hotel',
                'motel',
                'museum',
                'picnic_site',
                'theme_park',
                'viewpoint',
                'zoo') OR
    (tourism = 'information' and information = 'office') OR
    shop IN ('alcohol',
             'bakery',
             'bicycle',
             'car_repair',
             'convenience',
             'clothes',
             'florist',
             'hairdresser',
             'mall',
             'supermarket',
             'tyres',
             'department_store',
             'music',
             'butcher') OR
    historic IN ('archaeological_site',
                 'monument',
                 'memorial',
                 'manor',
                 'monastery') OR
    office IN (
              'government',
              'notary',
              'lawyer'
    ) OR
    railway = 'station' OR
    aeroway in ('terminal', 'helipad', 'aerodrome')
  )
ORDER BY
  CASE WHEN tourism = 'attraction' then 1
       WHEN tourism = 'viewpoint' then 2
       WHEN tourism in ('camp_site', 'caravan_site') then 3
       WHEN tourism is not null then 4
       WHEN historic is not null then 5
       WHEN railway is not null or aeroway is not null then 6
       WHEN amenity is not null then 7
       WHEN shop is not null then 8
       ELSE 9
  END
