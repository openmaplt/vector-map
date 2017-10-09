SELECT
  way AS __geometry__,
  name,
  (
    CASE
    WHEN amenity = 'arts_centre'
      THEN 'art-gallery'
    WHEN amenity = 'atm'
      THEN 'marker' -- TODO atm
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'car_wash'
      THEN 'marker' -- TODO: car_wash
    WHEN amenity = 'cinema'
      THEN 'cinema'
    WHEN amenity = 'clinic'
      THEN 'marker' -- TODO: clinic
    WHEN amenity = 'courthouse'
      THEN 'marker' -- TODO: courthouse
    WHEN amenity = 'dentist'
      THEN 'dentist'
    WHEN amenity = 'doctors'
      THEN 'doctor'
    WHEN amenity = 'fast_food'
      THEN 'fast_food'
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
      THEN 'marker' -- TODO: tower

    WHEN tourism = 'attraction' and "attraction:type" = 'hiking_route'
      THEN 'marker' -- TODO: hiking route
    WHEN tourism = 'attraction'
      THEN 'attraction'
    WHEN tourism = 'information'
      THEN 'information'
    WHEN tourism in ('camp_site', 'caravan_site')
      THEN 'campsite'
    WHEN tourism in ('chalet', 'hostel', 'motel', 'guest_house')
      THEN 'home' -- TODO: split, fix icon
    WHEN tourism = 'hotel'
      THEN 'lodging'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'picnic_site'
      THEN 'picnic_site'
    WHEN tourism = 'viewpoint'
      THEN 'viewpoint'

    WHEN historic = 'archaeological_site' and site_type = 'fortification'
      THEN 'hillfort'
    WHEN historic in ('monument', 'memorial')
      THEN 'marker' -- TODO: memorial
    WHEN historic = 'archaeological_site' and site_type = 'tumulus'
      THEN 'tumulus'
    WHEN historic = 'manor'
      THEN 'marker' -- TODO: manor
    WHEN historic = 'monastery'
      THEN 'marker' -- TODO: monastery

    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    WHEN shop = 'car_repair'
      THEN 'marker' -- TODO car repair
    WHEN shop = 'bakery'
      THEN 'bakery'
    WHEN shop = 'bicycle'
      THEN 'bicycle'
    WHEN shop = 'clothes'
      THEN 'clothing_store'
    WHEN shop in ('supermarket', 'mall')
      THEN 'grocery'
    WHEN shop in ('convenience')
      THEN 'shop'
    WHEN shop = 'hairdresser'
      THEN 'hairdresser'

    WHEN office = 'government' or amenity = 'townhall'
      THEN 'town-hall'
    WHEN office in ('notary', 'lawyer')
      THEN 'marker' -- TODO notary
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
  "addr:housenumber" AS housenumber
FROM
  planet_osm_point
WHERE
  way && !bbox! AND
  (
    amenity IN ('arts_centre',
                'atm'
                'bank',
                'bar',
                'cafe',
                'car_wash',
                'cinema',
                'clinic',
                'college',
                'courthouse',
                'dentist',
                'doctors',
                'fast_food',
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
                'universite') OR
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
    shop IN ('alcohol',
             'bakery',
             'bicycle',
             'car_repair',
             'convenience',
             'clothes',
             'hairdresser',
             'mall',
             'supermarket') OR
    historic IN ('archaeological_site',
                 'monument',
                 'memorial',
                 'manor',
                 'monastery')
  )

UNION ALL

SELECT
  st_centroid(way) AS __geometry__,
  name,
  (
    CASE
    WHEN amenity = 'arts_centre'
      THEN 'art-gallery'
    WHEN amenity = 'atm'
      THEN 'marker' -- TODO atm
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'car_wash'
      THEN 'marker' -- TODO: car_wash
    WHEN amenity = 'cinema'
      THEN 'cinema'
    WHEN amenity = 'clinic'
      THEN 'marker' -- TODO: clinic
    WHEN amenity = 'courthouse'
      THEN 'marker' -- TODO: courthouse
    WHEN amenity = 'dentist'
      THEN 'dentist'
    WHEN amenity = 'doctors'
      THEN 'doctor'
    WHEN amenity = 'fast_food'
      THEN 'fast_food'
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
      THEN 'marker' -- TODO: tower

    WHEN tourism = 'attraction' and "attraction:type" = 'hiking_route'
      THEN 'marker' -- TODO: hiking route
    WHEN tourism = 'attraction'
      THEN 'attraction'
    WHEN tourism = 'information'
      THEN 'information'
    WHEN tourism in ('camp_site', 'caravan_site')
      THEN 'campsite'
    WHEN tourism in ('chalet', 'hostel', 'motel', 'guest_house')
      THEN 'home' -- TODO: split, fix icon
    WHEN tourism = 'hotel'
      THEN 'lodging'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'picnic_site'
      THEN 'picnic_site'
    WHEN tourism = 'viewpoint'
      THEN 'viewpoint'

    WHEN historic = 'archaeological_site' and site_type = 'fortification'
      THEN 'marker' -- TODO: hillfort
    WHEN historic in ('monument', 'memorial')
      THEN 'marker' -- TODO: memorial
    WHEN historic = 'archaeological_site' and site_type = 'tumulus'
      THEN 'marker' -- TODO: tumulus
    WHEN historic = 'manor'
      THEN 'marker' -- TODO: manor
    WHEN historic = 'monastery'
      THEN 'marker' -- TODO: monastery

    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    WHEN shop = 'car_repair'
      THEN 'marker' -- TODO car repair
    WHEN shop = 'bakery'
      THEN 'bakery'
    WHEN shop = 'bicycle'
      THEN 'bicycle'
    WHEN shop = 'clothes'
      THEN 'clothing_store'
    WHEN shop in ('supermarket', 'mall')
      THEN 'grocery'
    WHEN shop in ('convenience')
      THEN 'shop'
    WHEN shop = 'hairdresser'
      THEN 'hairdresser'

    WHEN office = 'government' or amenity = 'townhall'
      THEN 'town-hall'
    WHEN office in ('notary', 'lawyer')
      THEN 'marker' -- TODO notary
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
  "addr:housenumber" AS housenumber
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    amenity IN ('arts_centre',
                'atm'
                'bank',
                'bar',
                'cafe',
                'car_wash',
                'cinema',
                'clinic',
                'college',
                'courthouse',
                'dentist',
                'doctors',
                'fast_food',
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
                'universite') OR
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
    shop IN ('alcohol',
             'bakery',
             'bicycle',
             'car_repair',
             'convenience',
             'clothes',
             'hairdresser',
             'mall',
             'supermarket') OR
    historic IN ('archaeological_site',
                 'monument',
                 'memorial',
                 'manor',
                 'monastery')
  )
