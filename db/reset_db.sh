#!/usr/bin/env bash

if [ ! -e data.pbf ]; then
	wget -O data.pbf http://download.geofabrik.de/europe/lithuania-latest.osm.pbf
fi

./osm2pgsql -s -c -C 1024 -E 3857 --multi-geometry -S ./osm2pgsql.style -d osm -U osm data.pbf
psql -d osm -U osm < index.sql
psql -d osm -U osm -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO osm;'
