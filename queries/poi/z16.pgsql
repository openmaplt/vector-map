SELECT
  way AS __geometry__,
  name,
  (
    CASE
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'cinema'
      THEN 'cinema'
    WHEN amenity = 'fast_food'
      THEN 'fast_food'
    WHEN amenity = 'fire_station'
      THEN 'fire-station'
    WHEN amenity = 'fuel'
      THEN 'fuel'
    WHEN amenity = 'hospital'
      THEN 'hospital'
    WHEN amenity = 'library'
      THEN 'library'
    WHEN amenity = 'pharmacy'
      THEN 'pharmacy'
    WHEN amenity = 'place_of_worship'
      THEN 'place_of_worship'
    WHEN amenity = 'police'
      THEN 'police'
    WHEN amenity = 'pub'
      THEN 'pub'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN amenity = 'school'
      THEN 'school'
    WHEN amenity = 'shelter'
      THEN 'shelter'
    WHEN amenity = 'theatre'
      THEN 'theatre'
    WHEN tourism = 'attraction'
      THEN 'attraction'
    WHEN tourism = 'information'
      THEN 'information'
    WHEN tourism = 'camp_site'
      THEN 'campsite'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'picnic_site'
      THEN 'picnic_site'
    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    WHEN shop = 'bakery'
      THEN 'bakery'
    WHEN shop = 'bicycle'
      THEN 'bicycle'
    WHEN shop = 'clothes'
      THEN 'clothing_store'
    WHEN shop in ('supermarket', 'convenience')
      THEN 'grocery'
    WHEN shop = 'hairdresser'
      THEN 'hairdresser'
    END
  ) AS kind,
  official_name,
  opening_hours,
  website,
  image
FROM
  planet_osm_point
WHERE
  way && !bbox! AND
  (
    amenity IN ('bank', 'bar', 'cafe', 'cinema', 'fast_food', 'fire_station', 'fuel', 'restaurant', 'pub', 'hospital', 'library', 'pharmacy', 'place_of_worship', 'police', 'school', 'shelter', 'theatre') OR
    tourism IN ('museum', 'attraction', 'camp_site', 'picnic_site') OR
    (tourism = 'information' and information = 'office') OR
    shop IN ('alcohol', 'bakery', 'bicycle', 'clothes', 'supermarket', 'convenience', 'hairdresser')
  )

UNION ALL

SELECT
  st_centroid(way) AS __geometry__,
  name,
  (
    CASE
    WHEN amenity = 'bank'
      THEN 'bank'
    WHEN amenity = 'bar'
      THEN 'bar'
    WHEN amenity = 'cafe'
      THEN 'cafe'
    WHEN amenity = 'cinema'
      THEN 'cinema'
    WHEN amenity = 'fast_food'
      THEN 'fast_food'
    WHEN amenity = 'fire_station'
      THEN 'fire-station'
    WHEN amenity = 'fuel'
      THEN 'fuel'
    WHEN amenity = 'hospital'
      THEN 'hospital'
    WHEN amenity = 'library'
      THEN 'library'
    WHEN amenity = 'pharmacy'
      THEN 'pharmacy'
    WHEN amenity = 'place_of_worship'
      THEN 'place_of_worship'
    WHEN amenity = 'police'
      THEN 'police'
    WHEN amenity = 'pub'
      THEN 'pub'
    WHEN amenity = 'restaurant'
      THEN 'restaurant'
    WHEN amenity = 'school'
      THEN 'school'
    WHEN amenity = 'shelter'
      THEN 'shelter'
    WHEN amenity = 'theatre'
      THEN 'theatre'
    WHEN tourism = 'attraction'
      THEN 'attraction'
    WHEN tourism = 'information'
      THEN 'information'
    WHEN tourism = 'camp_site'
      THEN 'campsite'
    WHEN tourism = 'museum'
      THEN 'museum'
    WHEN tourism = 'picnic_site'
      THEN 'picnic_site'
    WHEN shop = 'alcohol'
      THEN 'alcohol_shop'
    WHEN shop = 'bakery'
      THEN 'bakery'
    WHEN shop = 'bicycle'
      THEN 'bicycle'
    WHEN shop = 'clothes'
      THEN 'clothing_store'
    WHEN shop in ('supermarket', 'convenience')
      THEN 'grocery'
    WHEN shop = 'hairdresser'
      THEN 'hairdresser'
    END
  ) AS kind,
  official_name,
  opening_hours,
  website,
  image
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    amenity IN ('bank', 'bar', 'cafe', 'cinema', 'fast_food', 'fire_station', 'fuel', 'restaurant', 'pub', 'hospital', 'library', 'pharmacy', 'place_of_worship', 'police', 'school', 'shelter', 'theatre') OR
    tourism IN ('museum', 'attraction', 'camp_site', 'picnic_site') OR
    (tourism = 'information' and information = 'office') OR
    shop IN ('alcohol', 'bakery', 'bicycle', 'clothes', 'supermarket', 'convenience', 'hairdresser')
  )
