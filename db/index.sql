CREATE INDEX planet_osm_line_admin_level_boundary_index ON planet_osm_line (admin_level, boundary);
CREATE INDEX planet_osm_line_aeroway_index ON planet_osm_line (aeroway);
CREATE INDEX planet_osm_line_highway_index ON planet_osm_line (highway);
CREATE INDEX planet_osm_line_railway_service_index ON planet_osm_line (railway, service);
CREATE INDEX planet_osm_line_railway_index ON planet_osm_line (railway);
CREATE INDEX planet_osm_line_waterway_index ON planet_osm_line (waterway);
CREATE INDEX planet_osm_line_route_index ON planet_osm_line (route);
CREATE INDEX planet_osm_line_man_made_index ON planet_osm_line (man_made);

CREATE INDEX planet_osm_point_amenity_index ON planet_osm_point (amenity);
CREATE INDEX planet_osm_point_name_place_index ON planet_osm_point (name, place);
CREATE INDEX planet_osm_point_place_rank_index ON planet_osm_point (place, rank);
CREATE INDEX planet_osm_point_place_index ON planet_osm_point (place);
CREATE INDEX planet_osm_point_shop_index ON planet_osm_point (shop);
CREATE INDEX planet_osm_point_tourism_information_index ON planet_osm_point (tourism, information);
CREATE INDEX planet_osm_point_tourism_index ON planet_osm_point (tourism);

CREATE INDEX planet_osm_polygon_amenity_index ON planet_osm_polygon (amenity);
CREATE INDEX planet_osm_polygon_boundary_index ON planet_osm_polygon (boundary);
CREATE INDEX planet_osm_polygon_building_index ON planet_osm_polygon (building);
CREATE INDEX planet_osm_polygon_landuse_way_area_index ON planet_osm_polygon (landuse, way_area);
CREATE INDEX planet_osm_polygon_landuse_index ON planet_osm_polygon (landuse);
CREATE INDEX planet_osm_polygon_leisure_index ON planet_osm_polygon (leisure);
CREATE INDEX planet_osm_polygon_natural_index ON planet_osm_polygon ("natural");
CREATE INDEX planet_osm_polygon_shop_index ON planet_osm_polygon (shop);
CREATE INDEX planet_osm_polygon_tourism_information_index ON planet_osm_polygon (tourism, information);
CREATE INDEX planet_osm_polygon_tourism_index ON planet_osm_polygon (tourism);
CREATE INDEX planet_osm_polygon_waterway_index ON planet_osm_polygon (waterway);
CREATE INDEX planet_osm_polygon_way_area_index ON planet_osm_polygon (way_area);
